resource "aws_instance" "ec2-bastion" {
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
    "Name" : "eks-test-bastion"
  }

  provisioner "file" {
    source      = "${path.module}/files/cluster-autoscaler-policy.json"
    destination = "/home/ec2-user/cluster-autoscaler-policy.json"
    
    connection {
      type     = "ssh"
      user     = "ec2-user"
      host     = aws_instance.ec2-bastion.public_ip
      private_key = file("${path.module}/files/tgs-key.pem")
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/tgs-key.pem"
    destination = "/home/ec2-user/tgs-key.pem"
    
    connection {
      type     = "ssh"
      user     = "ec2-user"
      host     = aws_instance.ec2-bastion.public_ip
      private_key = file("${path.module}/files/tgs-key.pem")
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/ec2-install.sh"
    destination = "/home/ec2-user/ec2-install.sh"
    
    connection {
      type     = "ssh"
      user     = "ec2-user"
      # password = "${var.root_password}"
      host     = aws_instance.ec2-bastion.public_ip
      private_key = file("${path.module}/files/tgs-key.pem")
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
      private_key = file("${path.module}/files/tgs-key.pem")
    }
  }
  
  # provisioner "local-exec" {
  #   command      = "bash /home/ec2-user/ec2-run.sh"
  #   environment = {
  #     AWS_ACCESS_KEY_ID = "AKIARXMJEAZHQXZMA45B"
  #     AWS_SECRET_ACCESS_KEY = "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"
  #     AWS_DEFAULT_REGION = var.aws_region
  #   }
  # }
}

output "ec2_bastion_public_ip" {
  description = "ec2_bastion_public_ip"
  value       = aws_instance.ec2-bastion.public_ip
}

