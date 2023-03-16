# # Terraform Remote State Datasource
# data "terraform_remote_state" "eks" {
#   # backend = "local"

#   # config = {
#   #   path = "../01-eks/terraform.tfstate"
#   # }
#   backend = "s3"
#   config = {
#     bucket = "tgs-test3"
#     region = var.aws_region
#     key= "terraform.tfstate"
#     profile = "tgs"
#   }
  
#   outputs = {
# 	  aws_region = var.aws_region
#   }
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = var.eks_cluster_id
# }