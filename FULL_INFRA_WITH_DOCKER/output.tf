output "ssh_connexion" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${aws_instance.main-server.public_dns}"
}
output "jenkins_url" {
  value = "${aws_instance.main-server.public_ip}:8080"
}
# output "jenkins_password_file" {
#   value = "The Jenkins initial password is in the file called : initial_jenkins_pwd.txt in the remote server"
# }
output "JFROG_url" {
  value = "${aws_instance.main-server.public_ip}:8081"
}

output "HASHICORP_VAULT_URL" {
  value = "${aws_instance.main-server.public_ip}:8200"
}

output "HASHICORP_VAULT_TOKEN" {
  value = "${var.vault_token}"
}
output "jenkins_initial_password" {
  value = "local_initial_jenkins_pwd.txt"
}