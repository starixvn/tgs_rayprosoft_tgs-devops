provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      date      = "2023-08-10"
      tgsenv = "prod-test"
    }
  }
}