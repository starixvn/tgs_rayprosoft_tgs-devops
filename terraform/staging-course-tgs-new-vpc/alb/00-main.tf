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
  profile = var.aws_profile
  region  = var.aws_region
}
