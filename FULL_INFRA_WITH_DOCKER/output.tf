
output "Connexion_link_for_the_splunk_server" {
  value = aws_instance.main-server.public_ip
}

output "ssh_connexion" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${aws_instance.main-server.public_dns}"
}


# Output the content
# output "file_content" {
#   value = data.template_file.remote_file.rendered
# }