module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  # VPC 基本设置
  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["ap-east-1a","ap-east-1b", "ap-east-1c"]
  # 公有网段
  public_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  public_subnet_tags = {
    "Name" = "eks-public-subnets"
  }
  # 私有网段
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  private_subnet_tags = {
    "Name" = "eks-private-subnets"
  }

  # 启用 DNS 主机
  enable_dns_hostnames = true
  # 启用 DNS 支持
  enable_dns_support = true

  # 每个可用区一个NAT网关
  enable_nat_gateway     = true
  single_nat_gateway     = true
  # one_nat_gateway_per_az = true

  # 共同标签
  tags = {
    Owner = "tgs"
    Env   = "dev"
  }

  vpc_tags = {
    Name = "eks-vpc"
  }
}
