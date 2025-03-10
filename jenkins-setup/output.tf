# print the url of the jenkins server
output "jenkins_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}

# print the url of the jenkins server
output "ssh_connection_command" {
  value     = join ("", ["ssh -i ${var.project-name}.pem ec2-user@", aws_instance.ec2_instance.public_dns])
}
