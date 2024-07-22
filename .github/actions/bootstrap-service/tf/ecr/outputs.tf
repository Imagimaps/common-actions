output "arn" {
  value = aws_ecr_repository.service.arn
}

output "registry_id" {
  value = aws_ecr_repository.service.registry_id
}

output "repository_url" {
  value = aws_ecr_repository.service.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.service.name
}
