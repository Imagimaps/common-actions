// TODO: Add Secrets Manager for Service Secrets
// Input list of secret names and create them in Secrets Manager
// Ignore values in the secret

resource "aws_ecr_repository" "service" {
  name                 = "${var.project}/service/${var.service_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.service.name

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPull",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
        ],
        # "Condition" : {
        #   "StringEquals" : {
        #     "aws:PrincipalOrgID" : "ou-xkxl-ltgnvnxi"
        #   },
        #   # "StringLike" : {
        #   #   "aws:PrincipalArn" : "arn:aws:iam::*:role/${var.project}/ecr/*"
        #   # }
        #   # "ForAnyValue:StringLike": {
        #   #   "aws:PrincipalOrgPaths": "o-YOURORGANIZATIONID/*"
        #   # }
        # }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "delete_stale_images" {
  repository = aws_ecr_repository.service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images past 15 builds ago",
        selection    = {
          tagStatus = "untagged",
          countType = "imageCountMoreThan",
          countNumber = 15
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Expire images older than 14 days",
        selection    = {
          tagStatus = "any",
          countType = "sinceImagePushed",
          countUnit = "days",
          countNumber = 14
        },
        action = {
          type = "expire"
        }
      },
    ]
  })
}
