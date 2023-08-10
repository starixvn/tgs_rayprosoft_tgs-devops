# https://github.com/squareops/terraform-aws-rds-postgresql/blob/main/example/complete/main.tf

locals {
  region         = "ap-east-1"
  name           = "test-postgresql"
  vpc_id         = "vpc-0b86a361eb192585e"
  family         = "postgres14"
  subnet_ids     = ["subnet-0dea0052cfe6cb72e","subnet-0d56c08c7c467c6fb","subnet-09003ce42db3d99af","subnet-02a209b6c0dd9b4d4","subnet-0de015977d3c9aa18","subnet-0d1cf87af016cf91a"]
  environment    = "db"
  kms_key_arn    = "arn:aws:kms:ap-east-1:060812454361:key/db7a1fde-854a-4943-b9c0-3464587eb398"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  allowed_security_groups = ["db-production","rds-ec2-1"]
  additional_tags = {
    date      = "2023-08-10"
    tgsenv = "prod-test"
  }
}

module "rds-pg" {
  source                           = "squareops/rds-postgresql/aws"
  name                             = local.name
  db_name                          = "postgres"
  multi_az                         = "true"
  family                           = local.family
  vpc_id                           = local.vpc_id
  subnet_ids                       = local.subnet_ids ## db subnets
  environment                      = local.environment
  kms_key_arn                      = local.kms_key_arn
  engine_version                   = local.engine_version
  instance_class                   = local.instance_class
  master_username                  = "postgres"
  allocated_storage                = "50"
  publicly_accessible              = true
  skip_final_snapshot              = true
  backup_window                    = "03:00-06:00"
  maintenance_window               = "Mon:00:00-Mon:03:00"
  final_snapshot_identifier_prefix = "final"
  allowed_security_groups          = local.allowed_security_groups
  major_engine_version             = local.engine_version
  deletion_protection              = false
}