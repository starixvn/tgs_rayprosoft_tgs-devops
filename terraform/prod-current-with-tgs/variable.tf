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

variable "eks_name" {
  type    = string
  default = "tgs-taiwan-k8s"  
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-east-1"
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
