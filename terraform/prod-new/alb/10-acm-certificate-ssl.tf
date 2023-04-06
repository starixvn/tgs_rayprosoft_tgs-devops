# Resource: ACM Certificate
resource "aws_acm_certificate" "acm_cert_myeks" {
  domain_name       = "myeks.deeplearnaws.com"
  validation_method = "DNS"

  tags = {
    Owner = "KomaAWS"
  }

  lifecycle {
    # 创建新资源, 删除旧资源
    create_before_destroy = true
  }
}

# Outputs
output "acm_certificate_id" {
  value = aws_acm_certificate.acm_cert_myeks.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_cert_myeks.arn
}

output "acm_certificate_status" {
  value = aws_acm_certificate.acm_cert_myeks.status
}
