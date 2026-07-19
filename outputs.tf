output "alb_dns_name" {
  description = "Public URL of the load balancer"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  value = module.database.db_endpoint
}
