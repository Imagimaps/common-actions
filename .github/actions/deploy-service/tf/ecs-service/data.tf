data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs_fargate" {
  cluster_name = "${var.project}-${var.environment}-fargate"
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
    Project     = var.project
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

data "aws_db_instance" "shared" {
  db_instance_identifier = "${var.project}-shared"
}

data "aws_cloudwatch_log_group" "service_log_group" {
  name = "${var.project}/${var.service_name}/log-group"
}

data "aws_lb_target_group" "service_target_group" {
  name = "${var.project}-${var.service_name}-alb-tg"
}

data "aws_elasticache_cluster" "shared" {
  cluster_id = "${var.project}-${var.environment_short_name}-redis"
}

data "aws_elasticache_user" "platform_redis" {
  user_id = "platform-user"
}

data "aws_secretsmanager_secret" "platform_redis_user_password" {
  name = "${var.project}/${var.environment_short_name}/platform/redis_user_secrets"
}

data "aws_secretsmanager_secret_version" "platform_redis_user_password" {
  secret_id = data.aws_secretsmanager_secret.platform_redis_user_password.id
}
