# configured aws provider with proper credentials
provider "aws" {
  region    = var.aws_region
  profile   = var.profile
}


# launch the jenkins instance using ami : you can change this ami id with your own ami. 
resource "aws_instance" "jenkins_ec2_instance" {
  ami                    = var.jenkins_ami
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.jenkins_security_gp.id]
  key_name               = aws_key_pair.instance_key.key_name

  tags = {
    Name = "jenkins-server"
    Owner = "Hermann90"
  }
}


# launch the Nexus instance using ami
resource "aws_instance" "nexus_ec2_instance" {
  count = var.nexus_server ? 1 : 0
  ami                    = var.nexus_ami
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.nexus_security_gp.id]
  key_name               = aws_key_pair.instance_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    /home/ec2-user/nexus/bin/nexus start
  EOF

  tags = {
    Name = "nexus-server"
    Owner = "Hermann90"
  }
  
}

resource "aws_instance" "qa_server" {
  count = var.qa_server ? 1 : 0
  ami   = data.aws_ami.ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.qa_uat_security_gp.id]
  key_name = aws_key_pair.instance_key.key_name
  user_data            = file("qa_uat.sh")
  tags = {
    Name = "qa-server"
    Owner = "Hermann90"
  }
  # other instance configuration here
}

resource "aws_instance" "uat_server" {
  count = var.uat_server ? 1 : 0
  ami   = data.aws_ami.ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.qa_uat_security_gp.id]
  key_name = aws_key_pair.instance_key.key_name
  user_data            = file("qa_uat.sh")
   tags = {
    Name = "uat-server"
    Owner = "Hermann90"
  }
  # other instance configuration here
}
# an empty resource block
resource "null_resource" "name" {
  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    hosts        = [aws_instance.jenkins_ec2_instance.public_ip, aws_instance.nexus_ec2_instance.public_ip, aws_instance.qa_server.public_ip, aws_instance.uat_server.public_ip]
  }
  # wait for ec2 to be created
  depends_on = [aws_instance.jenkins_ec2_instance, aws_instance.nexus_ec2_instance, aws_instance.uat_server, aws_instance.qa_server]
}

#######

