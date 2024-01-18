# print the url of the jenkins server
output "jenkins_url" {
  value     = module.jenkins.jenkins_url
}

# print the url of the jfrog server
output "jfrog_ssh_connection_command" {
  value     = module.jenkins.jfrog_ssh_connection_command
}

# print the url of the jfrog server
output "jenkins_ssh_connection_command" {
  value     = module.jenkins.jenkins_ssh_connection_command
}