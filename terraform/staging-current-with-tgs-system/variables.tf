# Variables


# Map Users

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::060812454361:user/lunyi.52051"
      username = "lester.wei"
      groups   = ["system:masters"]
    }
  ]
}


# Local Variables

locals {
  name            = "tgs-k8s-staging"
  cluster_version = "1.28"
  profile 		  = "tgs"
  region          = "ap-east-1"
  project         = "tgs"
  key             = "tgs-key"
  vpc             = "vpc-0b86a361eb192585e"
  public_subnets  = ["subnet-02a209b6c0dd9b4d4","subnet-0de015977d3c9aa18","subnet-0d1cf87af016cf91a"]
  private_subnets = ["subnet-0dea0052cfe6cb72e","subnet-0d56c08c7c467c6fb","subnet-09003ce42db3d99af"]
  userdata        = "" # add any commands to append to user data if needed
}