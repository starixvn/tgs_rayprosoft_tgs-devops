# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "microservices_home" {
  metadata {
    name = "microservices-home"
    labels = {
      app = "microservices-home"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "microservices-home"
      }
    }

    template {
      metadata {
        labels = {
          app = "microservices-home"
        }
      }

      spec {
        container {
          image = "komavideo/microservices-home:v1"
          name  = "microservices-home"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}
