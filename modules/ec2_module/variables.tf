variable "instancetype" {
  type        = string
  description = "set aws instance type"
}

variable "aws_common_tags" {
  type        = map(any)
  description = "set aws tag"
}

variable "ebs_volume_size" {
  type        = number
  description = "size of the ebs volume"
}