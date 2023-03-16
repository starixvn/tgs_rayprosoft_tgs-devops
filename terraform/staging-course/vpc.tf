module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  # TF 名称
  name = "eks-vpc"
  # IP 地址段
  cidr = "10.0.0.0/16"
  # 启用 DNS 主机
  enable_dns_hostnames = true
  # 启用 DNS 支持
  enable_dns_support = true

  # 配置使用的 AZ 区
  azs = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  # 配置公有网段(会自动在路由表中配置IGW)
  public_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  # 配置私有网段
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  # 公有网段 TagName
  public_subnet_tags = {
    "Name" = "${local.appName}-public-subnets"
  }
  # 私有网段 TagName
  private_subnet_tags = {
    "Name" = "${local.appName}-private-subnets"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Owner = "${local.appName}-Eks"
  }

    vpc_tags = {
    # 赋予 tagName 标签
    "Name" = "eks-vpc"
  }
}