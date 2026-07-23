output "alb_dns_name" {
  description = "Public URL of the load balancer"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "cloudfront_domain_name" {
  description = "The public URL users will visit - CloudFront's free default domain"
  value       = module.cdn.distribution_domain_name
}

output "site_url" {
  description = "The final public HTTPS URL"
  value       = "https://${module.cdn.distribution_domain_name}"
}
