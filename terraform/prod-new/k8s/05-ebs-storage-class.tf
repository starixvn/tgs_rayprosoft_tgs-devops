# 注册: Kubernetes Storage Class
resource "kubernetes_storage_class_v1" "ebs_sc" {
  depends_on = [
    aws_eks_addon.eks_addon_csi_driver
  ]

  metadata {
    # EBS类名称(后面会引用到)
    name = "ebs-sc"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  reclaim_policy = "Retain"
}
