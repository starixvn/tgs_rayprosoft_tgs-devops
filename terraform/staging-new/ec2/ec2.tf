module "ec2-bastion" {
  #depends_on = [module.vpc]
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.0.0"

  name          = "${local.appName}-bastion-staging-test"
  ami           = var.instance_ami_id
  instance_type = var.instance_type
  key_name      = var.instance_keypair

  # 指定网段生成
  subnet_id = var.subnet_id

  # 用户数据
  user_data = file("${path.module}/ec2-userdata.sh")

  # 指定 Web 安全组
  vpc_security_group_ids = [module.bastion_server_sg.security_group_id]

  tags = {
    "Name" : "${local.appName}-bastion-staging-test"
  }
}
