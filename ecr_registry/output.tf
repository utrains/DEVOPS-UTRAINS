output "registry_uri" {
  value = aws_ecr_repository.ecr_repo.repository_url
}