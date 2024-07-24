resource "aws_iam_role" "ecr_readonly" {
  name = "${var.service_name}-ecr-read-only"
  path = "/${var.project}/ecr/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "ecs.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecr_readonly_inline_policy" {
  name = "${var.service_name}-ecr-readonly"
  role = aws_iam_role.ecr_readonly.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]
        Effect = "Allow"
        Resource = [
          data.aws_ecr_repository.service.arn
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_cloudwatch_log_group.service_log_group.arn}",
          "${aws_cloudwatch_log_group.service_log_group.arn}:*",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecr_task_runtime" {
  name = "${var.service_name}-task-runtime-role"
  path = "/${var.project}/ecr/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "ecs.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecr_task_runtime_inline_policy" {
  name = "${var.service_name}-ecr-task-runtime"
  role = aws_iam_role.ecr_task_runtime.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:ap-southeast-2:590183675784:secret:${var.project}/${var.service_name}/*",
          "arn:aws:secretsmanager:ap-southeast-2:590183675784:secret:discord-config-5XGytV",
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
