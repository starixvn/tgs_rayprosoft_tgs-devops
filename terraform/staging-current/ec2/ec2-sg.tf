module "bastion_server_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  
  name        = "eks-bastion-host-sg"
  description = "Security group for ec2 bastion with ssh ports open within VPC"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = [var.local_ip]
  ingress_rules            = ["ssh-tcp"]
  egress_rules = ["all-all"]

  tags = {
    Name = "EKS-BastionHost-SG"
  }
}