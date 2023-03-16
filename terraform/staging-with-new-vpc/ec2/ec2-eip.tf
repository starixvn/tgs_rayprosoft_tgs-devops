resource "aws_eip" "eks_bastion_host_eip" {
  depends_on = [aws_instance.ec2-bastion]
  instance   = aws_instance.ec2-bastion.id
  vpc        = true
  tags = {
    Name = "EKS-BastionHost-EIP"
  }
}
