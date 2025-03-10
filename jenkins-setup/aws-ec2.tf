# configured aws provider with proper credentials
provider "aws" {
  region    = var.region
  profile   = var.profile
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
resource "aws_security_group" "jenkins_ec2_security_group" {
  name        = "ec2-jenkins-sg"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_vpc.lab_vpc.id

  # allow access on port 8080 for Jenkins Server
  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
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
    Name = "utrains jenkins server security group"
  }
}

# launch the ec2 instance and install jenkis
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_ec2_security_group.id]
  key_name               = aws_key_pair.jenkins_key.key_name
  user_data              = file("installjenkins.sh")

  # Attach role to Ec2 instance
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name
  # Set the instance's root volume to 30 GB
  root_block_device {
    volume_size = 30
  }

  # Attach an additional 30 GB EBS volume
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "Jenkins-server"
  }
}

# Code to create Ami for our Jenkins server

/*
module "ami" {
  source = "../ami-creation"
  source_id = aws_instance.ec2_instance.id
  ami_name = "jenkins_ami"
}

output "jenkins_ami_id" {
  value = module.ami.ami_id
}
*/

## terraform state list 
### terraform state rm module.ami.aws_ami_from_instance.ami
