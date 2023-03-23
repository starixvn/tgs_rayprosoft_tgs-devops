# resource "aws_eks_cluster" "tgs-eks-cluster" {
#   depends_on = [
#     #module.vpc,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKSVPCResourceController,
#   ]

#   name = var.eks_name
#   role_arn = aws_iam_role.eks_master_role.arn
#   version = "1.22"

#   vpc_config {
#     subnet_ids = var.public_subnet_ids
#     endpoint_private_access = false
#     endpoint_public_access = true
#     public_access_cidrs = ["0.0.0.0/0"]
#   }

#   kubernetes_network_config {
#     service_ipv4_cidr = "172.30.0.0/16" 
#   }

#   enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

# }