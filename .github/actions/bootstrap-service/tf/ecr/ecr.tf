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
