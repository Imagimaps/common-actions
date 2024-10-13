variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  type        = string
  description = "Name of the Service"
}
