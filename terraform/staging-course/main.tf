###########################################################
# Terraform 基本设置
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46"
    }
  }
  
  backend "s3" {
    bucket = "tgs-test2"
    region = "ap-east-1"
    key= "terraform.tfstate"
    profile = "default"
	
	  dynamodb_table = "eks-tflock" 
  }
  required_version = ">= 1.3.6"
}

module eks {
  source = "./eks"
}

# module ec2 {
#   source = "./ec2"
#   vpc_id = module.eks.vpc_id
#   subnet_id = module.eks.public_subnet_id
# }

# module alb {
#    source = "./alb"
#    aws_iam_openid_connect_provider_extract_from_arn = module.eks.aws_iam_openid_connect_provider_extract_from_arn
#    aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn  
#    eks_cluster_id = module.eks.cluster_id
#    cluster_endpoint = module.eks.cluster_endpoint
#    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#    irsa_iam_role_arn =  module.eks.irsa_iam_role_arn
#    aws_region = var.aws_region
#    #vpc_id = module.vpc.vpc_id
# }

# module k8s {
#   source = "./k8s"
#   irsa_iam_role_arn = module.eks.irsa_iam_role_arn
#   eks_cluster_id = module.eks.cluster_id
#   ebs_csi_iam_role_arn = module.eks.ebs_csi_iam_role_arn
# }


###########################################################
# 提供商设置(云平台)
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}