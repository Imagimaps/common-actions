data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs_fargate" {
  cluster_name = "platform-${var.environment}-fargate"
}

data "aws_lb" "alb" {
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Environment = var.environment
    Project     = "Imagimaps"
  }
}

data "aws_subnets" "private_subnets" {
  tags = {
    Project = var.project
    Tier    = "private"
  }
}

data "aws_security_group" "ecs_fargate_sg" {
  name = "ecs-alb-sg"
}
