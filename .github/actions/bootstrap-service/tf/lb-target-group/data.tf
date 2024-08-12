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

data "aws_lb_listener" "api_listener" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 443
}
