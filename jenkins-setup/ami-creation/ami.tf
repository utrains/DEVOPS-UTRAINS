provider "aws" {
  region    = "us-east-1"
  profile   = "default"
}

resource "aws_ami_from_instance" "ami" {
  name               = "Jenkins_ami-1"
  source_instance_id = "your jenkins intance id"
}

# Output the AMI ID for reference
output "ami_id" {
  value = aws_ami_from_instance.ami.id
}
# This id will be used going forward in jenkins ami folder 
