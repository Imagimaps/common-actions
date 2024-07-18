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

variable "environment_short_name" {
  type = string
}

variable "service_name" {
  type    = string
  default = "imagimaps-bff"
}

variable "service_port" {
  type    = number
  default = 8080
}

variable "service_version" {
  type    = string
  default = "latest"
}

variable "task_cpu" {
  type    = number
  default = 512
}

variable "task_memory" {
  type    = number
  default = 1024
}

variable "container_cpu" {
  type    = string
  default = "128"
}

variable "container_memory" {
  type    = string
  default = "512"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 2
}
