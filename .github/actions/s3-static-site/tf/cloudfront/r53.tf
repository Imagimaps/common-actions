resource "aws_route53_record" "cf_alias" {
  name    = var.fq_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.root.zone_id
  
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
