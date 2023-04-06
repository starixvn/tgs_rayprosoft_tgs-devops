# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "microservices_auth" {
  metadata {
    name = "microservices-auth"
    labels = {
      app = "microservices-auth"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "microservices-auth"
      }
    }

    template {
      metadata {
        labels = {
          app = "microservices-auth"
        }
      }

      spec {
        container {
          image = "komavideo/microservices-auth:v1"
          name  = "microservices-auth"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}
