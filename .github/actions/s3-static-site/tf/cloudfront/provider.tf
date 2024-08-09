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
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      TF          = "true"
      Project     = var.project
      Environment = var.environment
    }
  }
}

terraform {
  backend "s3" {}
}
