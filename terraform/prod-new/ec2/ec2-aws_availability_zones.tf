data "aws_availability_zones" "availability_zones" {
  filter {
    # 区域状态
    name   = "opt-in-status"
    # opt-in-not-required: 已启用区域
    # not-opted-in:        未启用区域
    # opted-in:            启用选择加入的区域
    values = ["opt-in-not-required"]
  }
}