# Node Port Service: 主微服务
resource "kubernetes_service_v1" "microservices_home_service" {
  metadata {
    name = "microservices-home-service"
    annotations = {
      # 健康检查
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.microservices_home.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    type = "NodePort"
  }
}

# Node Port Service: 授权微服务
resource "kubernetes_service_v1" "microservices_auth_service" {
  metadata {
    name = "microservices-auth-service"
    annotations = {
      # 健康检查
      "alb.ingress.kubernetes.io/healthcheck-path" = "/auth"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.microservices_auth.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    type = "NodePort"
  }
}

# Node Port Service: 主微服务
resource "kubernetes_service_v1" "microservices_member_service" {
  metadata {
    name = "microservices-member-service"
    annotations = {
      # 健康检查
      "alb.ingress.kubernetes.io/healthcheck-path" = "/member"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.microservices_member.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    type = "NodePort"
  }
}
