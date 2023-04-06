# 使用 EKS Add-Ons 安装 EBS CSI 驱动程序
resource "aws_eks_addon" "eks_addon_csi_driver" {
  cluster_name             =var.eks_cluster_id
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = var.ebs_csi_iam_role_arn
}

variable "ebs_csi_iam_role_arn" {
  type = string
  default = "ebs_csi_iam_role_arn"
}