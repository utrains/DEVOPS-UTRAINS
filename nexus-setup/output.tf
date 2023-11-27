# print the url of the nexus server
output "nexus_server_url" {
    value = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8081"])
}

# print the ssh command to connect to the nexus server
output "ssh_connection" {
    value = join ("", ["ssh -i nexus_key_pair.pem ec2-user@", aws_instance.ec2_instance.public_dns])
}

# print the path to get the nexus admin password
output "nexus_admin_password" {
    value = "sudo cat ~/sonatype-work/nexus3/admin.password"
}