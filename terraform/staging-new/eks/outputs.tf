# EKS 集群输出
output "cluster_id" {
  description = "Cluster ID"
  value       = aws_eks_cluster.tgs-eks-cluster.id
}
output "cluster_arn" {
  description = "Cluster ARN"
  value       = aws_eks_cluster.tgs-eks-cluster.arn
}
output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = aws_eks_cluster.tgs-eks-cluster.endpoint
}
output "cluster_certificate_authority_data" {
  description = "Cluster certificate-authority-data"
  value       = aws_eks_cluster.tgs-eks-cluster.certificate_authority[0].data
}
output "cluster_version" {
  description = "Cluster version"
  value       = aws_eks_cluster.tgs-eks-cluster.version
}

output "aws_region" {
  description = "aws_region"
  value       =  "ap-east-1"
}