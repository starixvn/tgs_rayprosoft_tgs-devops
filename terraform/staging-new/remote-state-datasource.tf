data "terraform_remote_state" "eks" {
  # backend = "local"

  # config = {
  #   path = "../terraform.tfstate"
  # }

  backend = "s3"
  config = {
    bucket = "tgs-test2"
    region = "ap-east-1"
    key= "terraform.tfstate"
    profile = "default"
  }
}

data "aws_eks_cluster" "cluster" {
  name =  module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name =  module.eks.cluster_id
}