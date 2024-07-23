variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = "artifacts"
}

variable "service_name" {
  type        = string
  description = "Name of the Service"
}

variable "secret_names" {
  type        = list(string)
  description = "List of secret names to create in Secrets Manager"
}
