variable "aws_region" {
  description = "This is aws region"
  default     = "us-west-2"
  type        = string
}
variable "profile" {
  description = "user account to use"
  default     = "default"
}

variable "aws_instance_type_server" {
  description = "This is aws ec2 type "
  default     = "t2.large"
  type        = string
}

variable "aws_key" {
  description = "Key in region"
  default     = "my_cicd_key"
  type        = string
}

variable "vault_token" {
  description = "Token for first connexion in vault"
  default     = "VAULT_UTRAINS_TOKEN"
  type        = string
}

# Secret that will be used to connect to the JFrog server, from our Jenkins server.  
variable "jfrog_secret_username_and_password" {
  description = "JFrog secret username"
  type        = list(string)
}


variable "jfrog_secret_token" {
  description = "JFrog secret token"
  type        = string
}