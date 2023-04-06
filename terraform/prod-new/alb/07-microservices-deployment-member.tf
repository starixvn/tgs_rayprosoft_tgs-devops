# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "microservices_member" {
  metadata {
    name = "microservices-member"
    labels = {
      app = "microservices-member"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "microservices-member"
      }
    }

    template {
      metadata {
        labels = {
          app = "microservices-member"
        }
      }

      spec {
        container {
          image = "komavideo/microservices-member:v1"
          name  = "microservices-member"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}
