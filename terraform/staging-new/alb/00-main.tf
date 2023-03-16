###########################################################
# Terraform 基本设置
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }

  required_version = ">= 1.2.5"
}

###########################################################
# 提供商设置(云平台)
provider "aws" {
  profile = "default"
  region  = "ap-east-1"
}

provider "kubernetes" {
  # Configuration options
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

variable "cluster_endpoint" {
  description = "cluster_endpoint"
  type        = string
  default     = "cluster_endpoint"
}

variable "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  type        = string
  default     = "cluster_certificate_authority_data"
}
