variable "project_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "price_class" {
  description = "PriceClass_100 (US/EU/Canada only, cheapest), PriceClass_200, or PriceClass_All (all edge locations)"
  type        = string
  default     = "PriceClass_100"
}
