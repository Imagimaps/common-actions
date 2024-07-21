terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      OpenTofu    = "true"
      Project     = var.project
      Environment = var.environment
    }
  }
}

provider "aws" {
  alias  = "artifacts"
  region = var.aws_region
  assume_role_with_web_identity {
    role_arn                = "arn:aws:iam::${var.artifacts_aws_account_id}:role/platform/platform-deploy"
    session_name            = "ECS-Service-Deploy"
    # web_identity_token_file = "/Users/tf_user/secrets/web-identity-token"
  }
}

terraform {
  backend "s3" {}
}
