# resource "aws_eip" "eks_bastion_host_eip" {
#   depends_on = [module.ec2-bastion]
#   instance   = module.ec2-bastion.id
#   vpc        = true
#   tags = {
#     Name = "EKS-BastionHost-EIP"
#   }
# }
