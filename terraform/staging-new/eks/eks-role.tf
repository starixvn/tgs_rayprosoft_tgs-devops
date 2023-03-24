# resource "aws_iam_role" "eks_master_role" {
#   name          = "${local.appName}-terraform-eks-master-role"
  
#   assume_role_policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {"Service": "eks.amazonaws.com"},             
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# POLICY

#   tags = {
#     "Name" : "${local.appName}-terraform-eks-master-role"
#   }
# }


# resource "aws_iam_role_policy_attachment" "terraform-eks-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role = aws_iam_role.eks_master_role.name
# }

# resource "aws_iam_role_policy_attachment" "terraform-eks-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role = aws_iam_role.eks_master_role.name
# }
