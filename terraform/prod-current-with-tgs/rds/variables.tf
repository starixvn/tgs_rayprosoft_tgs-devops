variable "additional_tags" {
  description = "A map of additional tags to apply to the AWS resources"
  type        = map(string)
  default = {
    automation = "true"
  }
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks that are allowed to access the database"
  default     = []
  type        = list(any)
}

variable "security_group_ids" {
  description = "A list of Security Group IDs to allow access to the database"
  default     = ["sg-05d5fe9b1ad228e89","sg-00a049f6b1af0d40f"]
  type        = list(any)
}

variable "allocated_storage" {
  description = "The allocated storage capacity for the database in gibibytes (GiB)"
  default     = 50
  type        = number
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately or during the next maintenance window"
  default     = true
  type        = bool
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 5
}

variable "backup_window" {
  description = "The preferred window for taking automated backups of the database"
  default     = "03:00-06:00"
  type        = string
}

variable "create_random_password" {
  description = "Whether to create a random password for the RDS primary cluster"
  type        = bool
  default     = true
}

variable "create_security_group" {
  description = "Whether to create a security group for the database"
  default     = false
  type        = bool
}

variable "deletion_protection" {
  description = "Specifies whether accidental deletion protection is enabled"
  default     = false
  type        = bool
}

variable "enable_ssl_connection" {
  description = "Whether to enable SSL connection to the database"
  default     = true
  type        = bool
}

variable "db_name" {
  description = "The name of the automatically created database on cluster creation"
  default     = "tgs"
  type        = string
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster"
  default     = "postgres"
  type        = string
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  default     = "14.7"
  type        = string
}

variable "environment" {
  description = "Select enviroment type: dev, demo, prod"
  default     = "test"
  type        = string
}

variable "family" {
  description = "The version of the Postgresql DB family being created"
  default     = "postgres14"
  type        = string
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name for the final snapshot on cluster destroy"
  type        = string
  default     = "final"
}

variable "kms_key_arn" {
  description = "The ARN for the KMS encryption key. Set this to the destination KMS ARN when creating an encrypted replica. If storage_encrypted is set to true and kms_key_id is not specified, the default KMS key created in your account will be used"
  type        = string
  default     = "arn:aws:kms:ap-east-1:060812454361:key/db7a1fde-854a-4943-b9c0-3464587eb398"
}

variable "instance_class" {
  description = "The instance type for the database"
  default     = "db.t3.micro"
  type        = string
}

variable "major_engine_version" {
  description = "The major engine version for the database. Updating this argument results in an outage"
  default     = "14"
  type        = string
}

variable "master_username" {
  description = "The username for the RDS primary cluster"
  default     = "postgres"
  type        = string
}

variable "maintenance_window" {
  description = "The preferred window for performing database maintenance"
  default     = "Mon:00:00-Mon:03:00"
  type        = string
}

variable "multi_az" {
  description = "Enable multi-AZ for disaster recovery"
  default     = false
  type        = bool
}

variable "name" {
  description = "The name of the RDS instance"
  default     = "db-prod-test"
  type        = string
}

variable "port" {
  description = "The port number for the database"
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Specifies whether the RDS instance is publicly accessible over the internet"
  default     = true
  type        = bool
}

variable "random_password_length" {
  description = "The length of the randomly generated password for the RDS primary cluster (default: 10)"
  type        = number
  default     = 10
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a replicate database, and uses the specified value as the source database identifier"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If set to true, no DB snapshot is created. If set to false, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  type        = bool
  default     = true
}

variable "snapshot_identifier" {
  description = "Specifies whether to create the database from a snapshot. Use the snapshot ID found in the RDS console, e.g., rds:production-2015-06-26-06-05"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether to enable database encryption"
  default     = true
  type        = bool
}

variable "subnet_ids" {
  description = "A list of subnet IDs used by the database subnet group"
  default     = ["subnet-0dea0052cfe6cb72e","subnet-0d56c08c7c467c6fb","subnet-09003ce42db3d99af","subnet-02a209b6c0dd9b4d4","subnet-0de015977d3c9aa18","subnet-0d1cf87af016cf91a"]
  type        = list(any)
}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS cluster will be deployed"
  default     = "vpc-0b86a361eb192585e"
  type        = string
}
