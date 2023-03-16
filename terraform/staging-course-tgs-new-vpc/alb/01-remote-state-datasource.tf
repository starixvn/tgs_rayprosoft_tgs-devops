# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  # backend = "local"

  # config = {
  #   path = "../01-eks/terraform.tfstate"
  # }
  backend = "s3"
  config = {
    bucket = "tgs-test3"
    region = var.aws_region
    key= "terraform.tfstate"
    profile = "default"
  }
  
  outputs = {
	  aws_region = var.aws_region
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_id
}

variable "eks_cluster_id" {
  description = "eks_cluster_id"
  type        = string
  default     = "tgs-taiwan-staging2"
}

variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "ap-east-1"
}

variable "aws_profile" {
  description = "tgs"
  type        = string
  default     = "tgs"
}