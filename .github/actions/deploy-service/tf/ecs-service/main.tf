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

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.project}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecr_readonly.arn
  execution_role_arn       = aws_iam_role.ecr_readonly.arn
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  cpu    = var.task_cpu
  memory = var.task_memory
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "${var.service_name}-${var.service_version}"
      image     = "${data.aws_ecr_repository.service.repository_url}:${var.service_version}"
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
  }])
}

resource "aws_ecs_service" "service" {
  name            = "imagimaps-bff"
  cluster         = data.aws_ecs_cluster.ecs_fargate.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private_subnets.ids
    security_groups  = [data.aws_security_group.ecs_fargate_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_target_group.arn
    container_name   = "${var.service_name}-${var.service_version}"
    container_port   = var.container_port
  }

  force_new_deployment = true

  lifecycle {
    ignore_changes = [desired_count]
  }
}
