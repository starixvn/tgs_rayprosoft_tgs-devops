# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance
# https://github.com/foss-cafe/terraform-aws-documentdb-cluster/blob/master/main.tf

provider "aws" {
  region = local.region

  default_tags {
        tags = {
                Project = local.project
        }
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "prod-test-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier = "prod-test"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
  master_username    = "mongoadmin"
  master_password    = "kX4mHhJvV4v4L7KeudDn"
}