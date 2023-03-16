resource "aws_iam_role" "irsa_iam_role" {
  name = "eks-irsa-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:default:irsa-eks-sa"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "eks-irsa-iam-role"
  }
}

# Associate IAM Role and Policy
resource "aws_iam_role_policy_attachment" "irsa_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       =  aws_iam_role.irsa_iam_role.name
}

output "irsa_iam_role_arn" {
  description = "IRSA IAM Role ARN"
  value       = aws_iam_role.irsa_iam_role.arn
}

# output "irsa_iam_role_name" {
#   description = "IRSA IAM Role NAME"
#   value       = irsa_iam_role.
# }

# variable "irsa_iam_role_arn" {
#   type    = string
#   default = "irsa_iam_role_arn"  
# }

# variable "irsa_iam_role_name" {
#   type    = string
#   default = "irsa_iam_role_name"  
# }
