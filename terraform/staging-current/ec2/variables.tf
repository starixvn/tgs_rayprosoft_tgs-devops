variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "tgs"
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

variable "vpc_id" {
  description = "ID of the VPC in which security resources are deployed"
  type = string
}

variable "subnet_id" {
  description = "ID of the VPC in which security resources are deployed"
  type = string
}


variable "local_ip" {
  description = "Ip for ssh"
  type = string
  default = "114.33.41.237/32"
}
