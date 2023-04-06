# Resource: Kubernetes Service Account
resource "kubernetes_service_account_v1" "irsa_eks_sa" {
  metadata {
    name = "irsa-eks-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_iam_role_arn
    }
  }
}

variable "irsa_iam_role_arn" {
  type = string
  default = "irsa_iam_role_arn"
}