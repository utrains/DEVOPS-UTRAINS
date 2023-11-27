# Generates a secure private k ey and encodes it as PEM
resource "tls_private_key" "jfrog-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "jfrog-key" {
  key_name   = "jfrogkey"  
  public_key = tls_private_key.jfrog-key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "jfrog.pem"
  content  = tls_private_key.jfrog-key.private_key_pem
}
