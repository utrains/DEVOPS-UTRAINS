# configured aws provider with proper credentials
provider "aws" {
  region    = var.region
  profile   = "default"
}

# Create a VPC

resource "aws_vpc" "lab_vpc" {

  cidr_block           = var.VPC_cidr
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project-name}-VPC"
  }

}

# Create an Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "${var.project-name}-igw"
  }
}

# Create a route table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project-name}-public-route-table"
  }
}

# Associate the route table with the public subnet

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a public subnet

resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.AZ

  tags = {
    Name = "${var.project-name}-public-subnet"
  }
}

# create security group for the ec2 instance
resource "aws_security_group" "nexus_ec2_security_group" {
  name        = "ec2 nexus security group"
  description = "allow access on ports 8081 and 22"
  vpc_id      = aws_vpc.lab_vpc.id

  # allow access on port 8081 for nexus Server
  ingress {
    description      = "http proxy access"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22 ssh connection
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "utrains Nexus server security group"
  }
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# launch the ec2 instance and install nexus
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.nexus_ec2_security_group.id]
  key_name               = aws_key_pair.nexus_key.key_name
  # user_data            = file("install-nexus.sh")

  tags = {
    Name = "Nexus-server"
    owner = "Hermann90"
  }
}

# an empty resource block : Here we can connect to the server to run some bash commands that will allow us to install nexus.
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.ec2_instance.public_ip
  }


  # set permissions and run the  file
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",

      ## Install Java 8:
      "sudo yum install java-1.8.0-openjdk -y",

      # download the latest version of nexus
      "sudo wget https://download.sonatype.com/nexus/3/nexus-3.45.0-01-unix.tar.gz",

      "sudo yum upgrade -y",
      # Extract the downloaded archive file
      "tar -xvzf nexus-3.45.0-01-unix.tar.gz",
      "rm -f nexus-3.45.0-01-unix.tar.gz",
      "sudo mv nexus-3.45.0-01 nexus",

      # Start Nexus and check status
      "sh ~/nexus/bin/nexus start",
      "sh ~/nexus/bin/nexus status",
        ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.ec2_instance]
}
