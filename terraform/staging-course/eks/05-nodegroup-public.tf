# # Create AWS EKS Node Group - Public
# resource "aws_eks_node_group" "eks_nodegroup_public" {
#   depends_on = [
#     aws_eks_cluster.eks_cluster,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.terraform-eks-AmazonEC2ContainerRegistryReadOnly,
#   ]

#   cluster_name    = "terraform-eks"
#   node_group_name = "terraform-eks-nodegroup-public"
#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.eks-vpc.public_subnets

#   ami_type       = "AL2_x86_64"
#   capacity_type  = "SPOT"
#   disk_size      = 8
#   instance_types = ["t3.small"]

#   remote_access {
#     ec2_ssh_key = "ec2-key"
#     # source_security_group_ids = []
#   }

#   scaling_config {
#     desired_size = 3
#     min_size     = 1
#     max_size     = 5
#   }

#   # 集群更新设置
#   update_config {
#     max_unavailable = 1 # 最多不可用节点数, 太大的话影响系统负载
#     #max_unavailable_percentage = 50    # 最多不可用节点百分比
#   }

#   # 模块bug?
#   tags = {
#     Name = "terraform-eks-nodegroup-public"
#   }
# }
