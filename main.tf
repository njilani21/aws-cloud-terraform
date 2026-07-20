terraform {
  cloud {
    organization = "nasr-jilani"

    workspaces {
      name = "aws-cloud-terraform"
    }
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/Network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "compute" {
  source = "./modules/Compute"

  project_name           = var.project_name
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  alb_security_group_id  = module.network.alb_security_group_id
  app_security_group_id  = module.network.app_security_group_id
  instance_type          = var.instance_type
}

module "database" {
  source = "./modules/Database"

  project_name                = var.project_name
  database_subnet_ids         = module.network.database_subnet_ids
  database_security_group_id  = module.network.database_security_group_id
  db_username                 = var.db_username
  db_password                 = var.db_password
}
