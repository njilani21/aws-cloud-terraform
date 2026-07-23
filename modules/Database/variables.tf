variable "project_name" {
  type = string
}

variable "database_subnet_ids" {
  type = list(string)
}

variable "database_security_group_id" {
  type = string
}

variable "db_engine_version" {
  description = "MySQL engine version - must be an exact minor version currently offered by RDS in your region"
  type        = string
  default     = "8.0.44"
}

variable "db_instance_class" {
  description = "Not free-tier eligible once Multi-AZ is enabled - e.g. db.t3.medium or larger for production"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 1
}

variable "db_name" {
  type    = string
  default = "sampleAppDB"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
