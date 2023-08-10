locals {
  db_subnet_group_name            = var.db_subnet_group_name != "" ? var.db_subnet_group_name : join("", aws_docdb_subnet_group.this.*.name)
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name != "" ? var.db_cluster_parameter_group_name : join("", aws_docdb_cluster_parameter_group.this.*.name)
  appName         = "tgs"
  name            = "prod-test"
  region          = "ap-northeast-1"
  project         = "tgs"
  key             = "tgs-key"
  vpc             = "vpc-0b86a361eb192585e"
  public_subnets  = ["subnet-02a209b6c0dd9b4d4","subnet-0de015977d3c9aa18","subnet-0d1cf87af016cf91a"]
  private_subnets = ["subnet-0dea0052cfe6cb72e","subnet-0d56c08c7c467c6fb","subnet-09003ce42db3d99af"]
}