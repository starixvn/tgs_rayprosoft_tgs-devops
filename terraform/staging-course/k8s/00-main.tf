# ###########################################################
# # Terraform 基本设置
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.22"
#     }
#     kubernetes = {
#       source = "hashicorp/kubernetes"
#       version = "2.12.1"
#     }
#   }

#   required_version = ">= 1.2.5"
# }

# ###########################################################
# # 提供商设置(云平台)
# provider "aws" {
#   profile = "default"
#   region  =  "ap-east-1"
# }

# provider "kubernetes" {
#   # Configuration options
#   host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
#   cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# variable "aws_profile" {
#   description = "AWS Profile"
#   type        = string
#   default     = "default"
# }

# variable "aws_region" {
#   description = "AWS Region"
#   type        = string
#   default     = "ap-east-1"
# }