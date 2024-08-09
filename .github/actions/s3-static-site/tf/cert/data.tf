data "aws_route53_zone" "root" {
  name         = var.root_domain
  private_zone = false
}
