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
      TF          = "true"
      Project     = var.project
      Environment = var.environment
      CostCenter  = var.project
    }
  }
}

terraform {
  backend "s3" {}
}
