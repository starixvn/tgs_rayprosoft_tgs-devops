resource "aws_instance" "ec2-bastion" {
  depends_on        = [local.cluster_name]
  #source  = "terraform-aws-modules/ec2-instance/aws"
  #version = "4.0.0"

  #name          = "${local.app_name}-bastion"
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
    "Name" : "${local.app_name}-bastion"
  }

  provisioner "file" {
    source      = "${path.module}/files/ec2-run.sh"
    destination = "/home/ec2-user/ec2-run.sh"
    
    connection {
      type     = "ssh"
      user     = "ec2-user"
      # password = "${var.root_password}"
      host     = aws_instance.ec2-bastion.public_ip
      private_key = file("${path.module}/files/ec2-key.pem")
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/ec2-uninstall.sh"
    destination = "/home/ec2-user/ec2-uninstall.sh"
    
    connection {
      type     = "ssh"
      user     = "ec2-user"
      # password = "${var.root_password}"
      host     = aws_instance.ec2-bastion.public_ip
      private_key = file("${path.module}/files/ec2-key.pem")
    }
  }
}
