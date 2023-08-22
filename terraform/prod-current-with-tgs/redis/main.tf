# https://medium.com/@fullstacktips/how-to-create-redis-instance-on-aws-using-terraform-e90439d96c9

provider "aws" {
  version = "2.66.0"
  region = var.region
}

variable "region" {
  type        = string
  default     = "ap-east-1"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id              = "redis-test"
  engine                  = "redis"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  parameter_group_name    = "default.redis7"
  port                    = 6379
  subnet_group_name       = "tgs-redis"
  security_group_ids      = ["sg-02bbd834258ab9840"]  //tgs-redis
  preferred_availability_zones = ["${var.region}a"]
  maintenance_window      = "sun:00:00-sun:02:00"
  snapshot_retention_limit = 10
  snapshot_window         = "05:00-09:00"
  tags = {
    Name = "prod-redis-test"
  }
}