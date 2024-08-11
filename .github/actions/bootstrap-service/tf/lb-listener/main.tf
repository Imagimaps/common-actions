// TODO: Add listener rule to forward traffic to the target group based on path
// See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule

resource "aws_lb_target_group" "service_target_group" {
  name        = "${var.project}-${var.service_name}-alb-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    path     = "/health"
  }
}

resource "aws_lb_listener" "ecs_alb_listener_default" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }
}
