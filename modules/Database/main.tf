############################################
# DATABASE MODULE - MySQL, Multi-AZ RDS
# AWS maintains a synchronous standby replica
# in a second AZ and automatically fails over
# to it (~60-120s) if the primary AZ or
# instance fails. This is NOT free-tier
# eligible - you're billed for both instances.
############################################

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${var.project_name}-DB-subnetgroup"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password # pass via TF_VAR or a secrets manager - never hardcode

  # This is the key HA setting: AWS maintains a synchronous
  # standby replica in a second AZ and auto-fails over to it.
  multi_az = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.database_security_group_id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:30-mon:05:30"

  deletion_protection      = false
  skip_final_snapshot      = true
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  tags = {
    Name = "${var.project_name}-DB"
  }
}
