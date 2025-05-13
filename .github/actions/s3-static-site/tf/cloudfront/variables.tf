variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "root_domain" {
  description = "The root domain name"
  type        = string
}

variable "fq_domain_name" {
  description = "The fully qualified domain name"
  type        = string
}

variable "additional_domain_names" {
  description = "List of additional domain names to include in the CloudFront distribution"
  type        = list(string)
  default     = []
}
