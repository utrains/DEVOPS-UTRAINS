# Output the AMI ID for reference
output "ami_id" {
  value = aws_ami_from_instance.ami.id
}