# print the url of the server
output "jenkins_ssh_connection_command" {
  value     = join ("", ["ssh -i ",var.aws_key,".pem ec2-user@", aws_instance.jenkins_ec2_instance.public_dns])
}
# print the url of the jenkins server
output "jenkins_url" {
  value     = join ("", ["http://", aws_instance.jenkins_ec2_instance.public_dns, ":", "8080"])
}

# print the url of the jfrog server
output "jfrog_ssh_connection_command" {
  value = var.jfrog_server ? "ssh -i ${var.aws_key}.pem ubuntu@${aws_instance.jfrog_ec2_instance[0].public_dns}" : null
  #value     = var.jfrog_server ? join ("", ["ssh -i ", var.aws_key,".pem " ,"ubuntu@", aws_instance.jfrog_ec2_instance[0].public_dns]) : null
}
# print the url of the jenkins server
output "jfrog_url" {
  value     = var.jfrog_server ? join ("", ["http://", aws_instance.jfrog_ec2_instance[0].public_dns, ":", "8081"]) : null
}

# print the url of the jfrog server
output "jenkins_ssh_connection_command" {
  value     = module.jenkins.jenkins_ssh_connection_command
}
output "sonar_url" {
  value = module.jenkins.sonar_url
}