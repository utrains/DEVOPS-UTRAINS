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

  # Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "jfrog-Web-SG"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
      description = "ingress port "
      #from_port   = ingress.value
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress {
      description = "ingress port "
      #from_port   = ingress.value
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jfrog-Web-SG"
  }
}

  


 
#create ec2 instances 

resource "aws_instance" "JfrogInstance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.jfrog-key.key_name
  user_data              = file("jfrog.sh")
 
  tags = {
    Name = "Jfrog instance"
  }
  
}

# Code to create Ami for our Jfrog server

/*
module "ami" {
  source = "../ami-creation"
  source_id = aws_instance.JfrogInstance.id
  ami_name = "jfrog_ami"
}

output "jfrog_ami_id" {
  value = module.ami.ami_id
}


## terraform state list 
### terraform state rm module.ami.aws_ami_from_instance.ami
*/

