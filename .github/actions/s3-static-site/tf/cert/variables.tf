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

variable "requested_fq_domain" {
  description = "The fully qualified domain name to request a certificate for"
  type        = string
}

variable "root_domain" {
  description = "The root domain name"
  type        = string
}
