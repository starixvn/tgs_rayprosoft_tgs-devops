# resource "aws_eks_node_group" "eks_nodegroup_private" {
#   depends_on = [
#     aws_eks_cluster.tgs-eks-cluster,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEC2ContainerRegistryReadOnly,
#   ]

#   cluster_name = var.eks_name
#   node_group_name = "${var.eks_name}-nodegroup-private"
#   node_role_arn = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids = var.private_subnet_ids

#   ami_type = "AL2_x86_64"
#   capacity_type = "SPOT"
#   disk_size = 8
#   instance_types = ["t3.micro"]

#   remote_access {
#     //ec2_ssh_key = var.instance_keypair
#     source_security_group_ids = []
#   }

#   scaling_config {
#     desired_size = 1
#     max_size = 2
#     min_size = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   tags = {
#     Name = "terraform-eks-nodegroup-private"
#   }
# }