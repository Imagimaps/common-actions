locals {
  db_name     = "${var.service_name}-${var.environment}"
  db_user     = "${var.service_name}"
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["DB_PASSWORD"]
}

resource "aws_cloudwatch_log_group" "service_log_group" {
  name              = "${var.project}/${var.service_name}/log-group"
  retention_in_days = 7
}

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

// TODO: Add listener rule to forward traffic to the target group based on path
// See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.project}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecr_task_runtime.arn
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "PORT"
          value = "${tostring(var.container_port)}"
        },
        {
          name  = "HOST_TYPE"
          value = "AWS"
        },
        {
          name  = "DB_CON_TYPE"
          value = "rds_iam"
        },
        {
          name  = "DB_HOST"
          value = data.aws_db_instance.shared.address
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = local.db_name
        },
        {
          name  = "DB_USER"
          value = local.db_user
        },
        {
          name  = "DB_PASS"
          value = local.db_password
        }
      ]
  }])
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
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
