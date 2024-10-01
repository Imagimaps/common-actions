locals {
  db_name     = "${var.service_name}-${var.environment}"
  db_user     = "${var.service_name}"
}

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
      enable_cloudwatch_logging = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = data.aws_cloudwatch_log_group.service_log_group.name
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
          name  = "REDIS_URL"
          value = data.aws_elasticache_cluster.shared.cache_nodes.0.address
        },
        {
          name  = "REDIS_USER"
          value = data.aws_elasticache_user.platform_redis.user_name
        },
        {
          name  = "REDIS_PASSWORD"
          value = data.aws_secretsmanager_secret_version.platform_redis_user_password.secret_string
        },
        {
          name  = "SERVICE_LB_LISTENER_DNS_NAME"
          value = "https://api-alb.${var.root_domain}"
        },
        {
          name  = "CDN_DNS_NAME"
          value = "https://cdn.${var.root_domain}"
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
    target_group_arn = data.aws_lb_target_group.service_target_group.arn
    container_name   = "${var.service_name}-${var.service_version}"
    container_port   = var.container_port
  }

  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
