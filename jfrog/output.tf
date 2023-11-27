output "ssh-command" {
  value = "ssh -i keypair.pem ec2-user@${aws_instance.JfrogInstance.public_dns}"
}

output "jfrog-url" {
  value = "http://${aws_instance.JfrogInstance.public_ip}:8081"
}
