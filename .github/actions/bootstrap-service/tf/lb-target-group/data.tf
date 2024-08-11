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
