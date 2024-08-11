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

variable "log_retention" {
  type        = number
  description = "Number of days to retain logs in CloudWatch"
  default     = 7
}
