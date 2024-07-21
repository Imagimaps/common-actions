data "aws_iam_role" "ecr_read_only" {
  provider = aws.artifacts
  name = "${var.service_name}-ecr-read-only"
}
