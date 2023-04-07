locals {
  appName = "tgs"
  name            = "tgs-taiwan-k8s2"
  cluster_version = "1.22"
  region          = "ap-east-1"
  project         = "tgs"
  key             = "tgs-key"
  vpc             = "vpc-0b86a361eb192585e"
  public_subnets  = ["subnet-02a209b6c0dd9b4d4","subnet-0de015977d3c9aa18","subnet-0d1cf87af016cf91a"]
  private_subnets = ["subnet-0dea0052cfe6cb72e","subnet-0d56c08c7c467c6fb","subnet-09003ce42db3d99af"]
  userdata        = "" # add any commands to append to user data if needed
}
