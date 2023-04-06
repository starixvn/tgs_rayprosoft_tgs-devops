# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  //backend = "local"

  //config = {
  //  path = "../terraform.tfstate"
  //}
  
  backend = "s3"
  config = {
    bucket = "tgs-test2"
    region = "ap-east-1"
    key= "terraform.tfstate"
    profile = "default"
  }
  
  outputs = {
	  aws_region = "ap-east-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name =  var.eks_cluster_id
}


variable "eks_cluster_id" {
  type = string
  default = "eks_cluster_id"
}