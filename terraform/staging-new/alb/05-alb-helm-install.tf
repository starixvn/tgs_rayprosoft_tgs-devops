# 使用 helm 安装 AWS Load Balancer Controller
# -> https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
resource "helm_release" "alb_controller" {
  depends_on = [aws_iam_role.alb_iam_role]
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  set {
    name = "image.repository"
    # 选择区域镜像: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
    value = "800184023465.dkr.ecr.ap-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_iam_role.arn
  }

  # 手动建立 IngressClass
  set {
    name  = "createIngressClassResource"
    value = "false"
  }

  set {
    name  = "vpcId"
    value =  var.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_id
  }
}

# Helm Release Outputs
output "alb_controller" {
  value = helm_release.alb_controller.metadata
}

variable "vpc_id" {
  type = string
  default = "vpc_id"
}