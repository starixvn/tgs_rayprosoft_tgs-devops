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
  default = "tgs-key"
}

variable "eks_name" {
  type    = string
  default = "tgs-taiwan-staging2"
}

variable "vpc_id" {
  description = "ID of the VPC in which security resources are deployed"
  default = "vpc-0b86a361eb192585e"
  type = string
}

variable "subnet_id" {
  description = "ID of the VPC in which security resources are deployed"
  default = "subnet-0d1cf87af016cf91a"
  type = string
}

