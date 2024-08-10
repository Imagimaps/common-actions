resource "aws_secretsmanager_secret" "secrets" {
  count        = length(var.secret_names)
  name         = "${var.project}/${var.service_name}/${var.secret_names[count.index]}"
  description  = "Secret for ${var.secret_names[count.index]}"
}
