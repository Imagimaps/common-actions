data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_role" "ecr_read_only" {
  name = "${var.service_name}-ecr-read-only"
}

data "aws_ecs_cluster" "ecs_fargate" {
  cluster_name = "platform-${var.environment}-fargate"
}

data "aws_subnets" "private_subnets" {
  tags = {
    Project = var.project
    Tier    = "private"
  }
}
