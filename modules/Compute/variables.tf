variable "project_name" {
  type = string
  default = "Sample"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "website_source_dir" {
  description = "Local path to the static website folder to upload to S3"
  type        = string
  default     = "../../html5-simple-personal-website-master"
}

# NOTE: user_data is no longer a plain variable default, because it needs to
# reference the S3 bucket name (a resource attribute), and variable defaults
# in Terraform cannot reference resources or data sources. It's now built as
# a `local` in main.tf instead - see `local.user_data` there.
