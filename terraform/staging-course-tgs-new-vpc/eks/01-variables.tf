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
      userarn  = "arn:aws:iam::060812454361:user/lester.wei"
      username = "lester.wei"
      groups   = ["system:masters"]
    }
  ]
}
