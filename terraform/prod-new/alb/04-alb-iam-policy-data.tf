# 数据源: ALB 策略权限
data "http" "alb_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

output "alb_iam_policy" {
  value = data.http.alb_iam_policy.response_body
}
