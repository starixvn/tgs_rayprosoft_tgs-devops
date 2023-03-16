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

variable "eks_cluster_id" {
  description = "eks_cluster_id"
  type        = string
  default     = "tgs-taiwan-staging2"
}

variable "cluster_endpoint" {
  description = "cluster_endpoint"
  type        = string
  default     = "cluster_endpoint"
}

variable "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  type        = string
  default     = "cluster_certificate_authority_data"
}
