output "ssh-command" {
  value = "ssh -i jfrog.pem ubuntu@${aws_instance.JfrogInstance.public_dns}"
}

output "jfrog-url" {
  value = "http://${aws_instance.JfrogInstance.public_ip}:8081"
}
