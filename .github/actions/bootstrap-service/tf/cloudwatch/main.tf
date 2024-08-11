resource "aws_cloudwatch_log_group" "service_log_group" {
  name              = "${var.project}/${var.service_name}/log-group"
  retention_in_days = var.log_retention
}
