resource "aws_ssm_parameter" "service_log_level" {
  name        = "/service/${var.service_name}/log_level"
  description = "Log level for the service. Valid values are 'fatal', 'error', 'warn', 'info', 'debug', 'trace' or 'silent'"
  type        = "String"
  value       = "info"
  tags = {
    Environment = var.environment
    Project     = var.project
    Service     = var.service_name
  }
}