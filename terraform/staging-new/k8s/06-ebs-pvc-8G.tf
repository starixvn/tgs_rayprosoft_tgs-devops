# Resource: Persistent Volume Claim
resource "kubernetes_persistent_volume_claim_v1" "pvc" {
  depends_on = [
    kubernetes_storage_class_v1.ebs_sc
  ]
  metadata {
    name = "ebs-redmine-mysql-pvc"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.ebs_sc.metadata.0.name
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
  # 不等待挂载
  wait_until_bound = false
  # 等待挂载
  # wait_until_bound = true
}
