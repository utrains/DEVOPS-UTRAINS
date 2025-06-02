# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "devops VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "devops-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "devops IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-rt.id
}


# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "cicd-security-group"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jfrog Port"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "sonarqube port"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Open port for Trivy
  ingress {
    description = "trivy port"
    from_port   = 4954
    to_port     = 4954
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Open port for JFOG
  ingress {
    description = " port"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    description = "Vault port"
    from_port   = 8200
    to_port     = 8200
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
    Name = "jenkins-jfrog-SG"
    Owner = "Hermann90"
  }
}


#data for amazon linux
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

# create static ip
# resource "aws_eip" "my-eip" {
#   domain = "vpc"
#   instance = aws_instance.main-server.id
# }
#create ec2 instances
resource "aws_instance" "main-server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type_server
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.ec2-key.key_name
  

  # Attach role to Ec2 instance
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  # Set the instance's root volume to 50 GB
  root_block_device {
    volume_size = 50
  }


  tags = {
    Name        = "CICD-Server"
    owner       = "utrains"
    Environment = "dev"
  }

    provisioner "file" {
    source      = "${path.module}/installations_scripts"
    destination = "/home/ec2-user/"

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(local_file.ssh_key.filename)
      host        = self.public_ip
      timeout     = "1m"
    }
  }
}

# This Null Resource can install dos2unix and Docker
resource "null_resource" "install_docker" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.main-server.public_ip
  }
  # set permissions and run the  file
  provisioner "remote-exec" {
    
    inline = [
      "sudo yum update -y ",
      "sudo yum install dos2unix -y",
      
      "dos2unix /home/ec2-user/installations_scripts/*.sh",
      
      # Install docker
      "sh installations_scripts/install_docker.sh",
    ] 
  }
  # wait the main-server end his installation
  depends_on = [aws_instance.main-server, local_file.ssh_key]
}


# Wait for scripts to be installed in the first two null_resources before installing the last null_resource.
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.main-server.public_ip
  }
  # set permissions and run the  file
  provisioner "remote-exec" {
    
    inline = [
      "ls",
      "pwd",
      "sh installations_scripts/install_java.sh",

      "sh installations_scripts/install_jfrog.sh",    
      
      # Jenkins configuration
      #"sudo sh installations_scripts/install_jenkins.sh",

      # # Install Trivy
      "sudo sh installations_scripts/install_trivy.sh",

      # Install SonarQube
      "sudo sh installations_scripts/install_sonar_using_docker.sh",
      
      # Install Vault, then create a policy and a token for allow Jenkins to access the secrets in vault
      "sudo sh installations_scripts/install_vault.sh ${var.jfrog_secret_username_and_password[0]} ${var.jfrog_secret_username_and_password[1]} ${var.jfrog_secret_token} ",
    ]
    
  }

  # wait the 2 null resource that install
  depends_on = [null_resource.install_docker, local_file.ssh_key]
}


resource "null_resource" "fetch_remote_file" {
   provisioner "local-exec" {
     command = "scp -o StrictHostKeyChecking=no -i ${local_file.ssh_key.filename} ec2-user@${aws_instance.main-server.public_ip}:/home/ec2-user/*.txt ."
   }

   depends_on = [null_resource.name]
 }

