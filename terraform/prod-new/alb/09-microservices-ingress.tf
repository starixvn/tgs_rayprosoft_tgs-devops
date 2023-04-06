# Kubernetes Service Manifest (Type: Load Balancer)
resource "kubernetes_ingress_v1" "microservices_ingress" {
  depends_on = [
    kubernetes_ingress_class_v1.ingress_class_default,
    aws_acm_certificate.acm_cert_myeks
  ]
  metadata {
    name = "microservices-ingress"
    annotations = {
      # Load Balancer Name
      "alb.ingress.kubernetes.io/load-balancer-name" = "microservices-ingress"
      # Ingress Core Settings
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      # Health Check Settings
      "alb.ingress.kubernetes.io/healthcheck-protocol"         = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = 20
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = 5
      "alb.ingress.kubernetes.io/success-codes"                = 200
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = 2
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = 2

      # 设置侦听端口
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTPS" = 443 }, { "HTTP" = 80 }])
      # 设置SSL证书
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.acm_cert_myeks.arn}"
      "alb.ingress.kubernetes.io/ssl-redirect"    = 443
    }
  }

  spec {
    ingress_class_name = "alb-ingress-class" # Ingress Class            
    default_backend {
      service {
        name = kubernetes_service_v1.microservices_home_service.metadata[0].name
        port {
          number = 80
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.microservices_auth_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path      = "/auth"
          path_type = "Prefix"
        }

        path {
          backend {
            service {
              name = kubernetes_service_v1.microservices_member_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path      = "/member"
          path_type = "Prefix"
        }
      }
    }
  }
}
