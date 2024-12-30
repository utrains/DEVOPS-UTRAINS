# resource "aws_instance" "example" {
#   ami           = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI
#   instance_type = "t2.micro"

#   # Add your SSH key here
#   key_name = "my-key"

#   provisioner "remote-exec" {
#     inline = [
#       # Replace '/path/to/your/file.txt' with the file you want to read
#       "cat /path/to/your/file.txt > /tmp/output.txt"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ec2-user" # Replace with your instance's username
#       private_key = file("~/.ssh/my-key.pem") # Path to your private key
#       host        = self.public_ip
#     }
#   }

#   tags = {
#     Name = "example-instance"
#   }
# }

# # Fetch the file content
# data "template_file" "remote_file" {
#   template = file("/tmp/output.txt")
# }

# # Output the content
# output "file_content" {
#   value = data.template_file.remote_file.rendered
# }
