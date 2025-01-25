output "ssh_connexion" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${aws_instance.main-server.public_dns}"
}
output "jenkins_url" {
  value = "${aws_instance.main-server.public_ip}:8080"
}
output "jenkins_password_file_location" {
  value = "The jinkins initial password is in the fale called : initial_jenkins_pwd.txt in the remote server"
}
output "JFROG_url" {
  value = "${aws_instance.main-server.public_ip}:8081"
}
