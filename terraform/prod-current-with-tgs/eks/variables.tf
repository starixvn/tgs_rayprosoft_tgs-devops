# AWS EC2 Instance Type
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
# AWS EC2 Image ID
variable "instance_ami_id" {
  description = "AMI Image ID"
  type        = string
  default     = "ami-05a3ab9cebecfeadc"
}
# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  type    = string
  default = "ec2-key"
}

variable "public_subnet_ids" {
  type    = list(string)
  default = ["10.0.20.25"]
}

variable "private_subnet_ids" {
  type    = list(string)
  default = ["10.0.20.25"]
}

variable "eks_name" {
  type    = string
  default = "tgs-k8s-prod"  
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::060812454361:user/lunyi.52051"
      username = "lester.wei"
      groups   = ["system:masters"]
    }
  ]
}
