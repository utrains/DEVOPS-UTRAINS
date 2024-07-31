variable aws_region {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}
variable "profile" {
  description = "user account to use"
  default = "default"
}
variable "jenkins_ami" {
 description = "Jenkins ami" 
 default = ""
}
variable "jfrog_ami" {
 description = "nexus ami" 
 default = ""
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

variable qa_server {
  description = "if qa server can be created"
  default     = false
  type        = bool
}

variable uat_server {
  description = "if qa server can be created"
  default     = false
  type        = bool
}
variable jfrog_server {
description = "if nexus server can be created"
  default     = false
  type        = bool
}

variable role_name {
  description = "if nexus server can be created"
  default     = "jenkinsAdminRoleAmi"
  type        = string
}

variable qa_uat_sg_name {
  description = "Name of UAT Security Group"
  default     = "qa-uat-security-group"
  type        = string
}

variable jfrog_sg_name {
  description = "Name of JFROG Security Group"
  default     = "jfrog-security-group"
  type        = string
}

variable jenkins_sg_name {
  description = "Name of Jenkins Security Group"
  default     = "jenkins-security-group"
  type        = string
}
