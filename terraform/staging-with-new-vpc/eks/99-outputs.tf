output "aws_region" {
  # AWS 区域
  value = var.aws_region
}

# # EKS 集群输出
output "cluster_id" {
  description = "Cluster ID"
  value       = module.eks.cluster_id
}
output "cluster_arn" {
  description = "Cluster ARN"
  value       =  module.eks.cluster_arn
}
output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.eks.cluster_endpoint
}
# output "cluster_certificate_authority_data" {
#   description = "Cluster certificate-authority-data"
#   value       = module.eks.cluster_certificate_authority_data[0].data
# }
output "cluster_version" {
  description = "Cluster version"
  value       = module.eks.cluster_version
}

output "vpc_id" {
  description = "vpc_id"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "public subnets"
  value       = module.vpc.public_subnets[0]
}