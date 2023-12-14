# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
}

  # Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "jfrog-Web-SG"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

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

