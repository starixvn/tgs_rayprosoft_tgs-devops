# 建立 AWS EKS 集群
resource "aws_eks_cluster" "eks_cluster" {
  # EKS 依赖角色
  depends_on = [
    aws_iam_role_policy_attachment.terraform-eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.terraform-eks-AmazonEKSVPCResourceController,
  ]

  name     = local.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.24"

  vpc_config {
    subnet_ids              = module.vpc.public_subnets
    endpoint_private_access = true
    endpoint_public_access  = true          # 启用了 Amazon EKS 公共 API 服务器终端节点
    public_access_cidrs     = ["0.0.0.0/0"] # 公有终端节点允许存取的 IP 范围
  }

  kubernetes_network_config {
    # 用于分配 Kubernetes 内部服务的 IP CIDR 块
    service_ipv4_cidr = "172.30.0.0/16"
  }

  # 启用 EKS 日志
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# resource "null_resource" "add_tolerations_dns" {
#   depends_on        = [local.cluster_name]
#   provisioner "local-exec" {
#       command = <<EOF
#       kubectl patch deploy -n kube-system coredns --type='json' -p='[{"op": "add", "path": "/spec/template/spec/tolerations/-", "value": {"operator": "Exists", "key": "dedicated","effect": "NoSchedule"}}]'
#   EOF
#     }
# }