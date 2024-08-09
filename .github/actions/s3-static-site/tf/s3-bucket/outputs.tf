output "website_domain" {
  value = aws_s3_bucket_website_configuration.this.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.this.website_endpoint
}
