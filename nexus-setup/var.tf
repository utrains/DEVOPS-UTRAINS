variable aws_region {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}

variable aws_instance_type {
  description = "This is aws ec2 type "
  default = "t2.medium"
  type        = string
}

variable aws_key {
  description = "Key in region"
  default     = "my_ec2_key"
  type        = string
}