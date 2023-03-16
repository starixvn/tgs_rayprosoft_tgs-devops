# AWS Region
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
      userarn  = "arn:aws:iam::118936045135:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::118936045135:user/lester.wei"
      username = "lester.wei"
      groups   = ["system:masters"]
    }
  ]
}
