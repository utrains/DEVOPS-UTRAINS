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
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  tags = {
    Name = "jenkins-server"
    Owner = "Hermann90"
  }
}


# launch the jfrog instance using ami
resource "aws_instance" "jfrog_ec2_instance" {
  count = var.jfrog_server ? 1 : 0
  ami                    = var.jfrog_ami
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.jfrog_security_gp.id]
  key_name               = aws_key_pair.instance_key.key_name
 /* user_data = <<-EOF
    #!/bin/bash
    /home/ec2-user/jfrog/bin/jfrog start
  EOF
*/
  tags = {
    Name = "jfrog-server"
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

}

resource "aws_instance" "uat_server" {
  count = var.uat_server ? 1 : 0
  ami   = data.aws_ami.ami.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name 
  vpc_security_group_ids = [aws_security_group.qa_uat_security_gp.id]
  key_name = aws_key_pair.instance_key.key_name
  user_data            = file("qa_uat.sh")
   tags = {
    Name = "uat-server"
    Owner = "Hermann90"
  }
  
}

# Code to create Ami for our Jenkins server

/*
module "jenkins-ami" {
  source = "../ami-creation"
  source_id = aws_instance.jenkins_ec2_instance.id
  ami_name = "jenkins_ami-2"

}
module "jfrog-ami" {
  source = "../ami-creation"
  source_id = aws_instance.jfrog_ec2_instance[0].id
  ami_name = "jfrog_ami-2"

}
output "jfrog_ami_id" {
  value = module.jfrog-ami.ami_id
}
output "jenkins_ami_id" {
  value = module.jenkins-ami.ami_id
}
*/


## terraform state list 
### terraform state rm module.jenkins-ami.aws_ami_from_instance.ami
### terraform state rm module.jfrog-ami.aws_ami_from_instance.ami
#### terraform destroy
