ariable region {
  description = "This is aws region"
  default     = "us-east-2"
  type        = string
}

variable "profile" {
  description = "user account to use"
  default = "default"
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
  default = "us-east-2a"
}

variable "project-name" {
  type    = string
  default = "jfrog"
}

# variable aws_instance_type {
#   description = "This is aws ec2 type "
#   default = "t2.medium"
#   type        = string
# }

# variable aws_key {
#   description = "Key in region"
#   default     = "my_ec2_key"
#   type        = string
# }

