output "distribution_domain_name" {
  value = aws_cloudfront_distribution.app.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront's fixed hosted zone ID, used for Route 53 alias records"
  value       = aws_cloudfront_distribution.app.hosted_zone_id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.app.id
}
