resource "aws_ecs_task_definition" "service" {
  family                   = "${var.project}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = data.aws_iam_role.ecr_read_only.arn
  execution_role_arn       = data.aws_iam_role.ecr_read_only.arn
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
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.service_name}:${var.service_version}"
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
    target_group_arn = data.aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = "${var.service_name}-${var.service_version}"
    container_port   = var.container_port
  }

  force_new_deployment = true

  lifecycle {
    ignore_changes = [desired_count]
  }
}
