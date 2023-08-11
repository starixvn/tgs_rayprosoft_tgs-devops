# https://github.com/squareops/terraform-aws-rds-postgresql/blob/main/example/complete/main.tf
# ref .terraform/modules/rds-pg/main.tf

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  region = "ap-east-1"
  tags = {
    Automation  = "true"
    Environment = var.environment
  }
  additional_tags = {
    date      = "2023-08-10"
    tgsenv = "prod-test"
  }
}

module "db" {
  source                           = "terraform-aws-modules/rds/aws"
  version                          = "~> 3.0"
  identifier                       = var.name //format("%s-%s", var.environment, var.name)
  name                             = var.db_name
  port                             = var.port
  engine                           = var.engine
  username                         = var.master_username
  multi_az                         = var.multi_az
  subnet_ids                       = var.subnet_ids
  kms_key_id                       = var.kms_key_arn
  instance_class                   = var.instance_class
  engine_version                   = var.engine_version
  allocated_storage                = var.allocated_storage
  storage_encrypted                = var.storage_encrypted
  publicly_accessible              = var.publicly_accessible
  replicate_source_db              = var.replicate_source_db
  vpc_security_group_ids           = var.security_group_ids
  skip_final_snapshot              = var.skip_final_snapshot
  snapshot_identifier              = var.snapshot_identifier
  maintenance_window               = var.maintenance_window
  backup_window                    = var.backup_window
  apply_immediately                = var.apply_immediately
  backup_retention_period          = var.backup_retention_period
  random_password_length           = var.random_password_length
  create_random_password           = var.create_random_password
  monitoring_interval              = "30"
  monitoring_role_name             = format("%s-%s-RDSPostgresql", var.name, var.environment)
  create_monitoring_role           = true
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix
  enabled_cloudwatch_logs_exports  = ["postgresql"]
  tags = merge(
    { "Name" = format("%s-%s", var.environment, var.name) },
    local.tags,
  )

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  deletion_protection = var.deletion_protection
}