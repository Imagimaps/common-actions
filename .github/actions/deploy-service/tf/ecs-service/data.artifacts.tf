data "aws_ecr_repository" "service" {
  provider = aws.artifacts
  name = "${var.project}/service/${var.service_name}"
}
