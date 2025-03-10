variable "region" {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}

variable aws_instance_type {
  description = "This is aws ec2 type "
  default = "t2.medium"
  type        = string
}

variable "VPC_cidr" {
  type = string
  default = "192.168.0.0/16" 
}

variable "public_subnet_cidr" {
  type = string
  default = "192.168.1.0/24"
}  

variable "AZ" {
  type = string
  default = "us-east-1a"
}

variable "project-name" {
  type    = string
  default = "nexus-setup-lab"
}
