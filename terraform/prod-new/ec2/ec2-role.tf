resource "aws_iam_role" "eks_bastion_host_role" {
  name = "eks_bastion_host_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "eks_bastion_host_role"
  }
}

resource "aws_iam_instance_profile" "eks_bastion_host_profile" {
  name = "eks_bastion_host_profile"
  role = aws_iam_role.eks_bastion_host_role.name
}

# 为角色绑定权限
resource "aws_iam_role_policy_attachment" "eks_bastion_host_role_AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_bastion_host_role.name
}
