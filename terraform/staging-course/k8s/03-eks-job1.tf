# Resource: Kubernetes Job
resource "kubernetes_job_v1" "eks_job1" {
  # EKS 依赖角色
  depends_on = [
    kubernetes_service_account_v1.irsa_eks_sa
  ]

  metadata {
    name = "eks-job1"
  }
  spec {
    template {
      metadata {
        labels = {
          app = "eks-job1"
        }
      }
      spec {
        # 赋予 Job 的服务角色
        service_account_name = kubernetes_service_account_v1.irsa_eks_sa.metadata.0.name
        container {
          name  = "eks-job1"
          image = "amazon/aws-cli:latest"
          # 列出存储桶
          args = ["s3", "ls"]
          # 列出 DynamoDB 表一览
          # args  = ["dynamodb", "list-tables"]
        }
        restart_policy = "Never"
      }
    }
  }
}
