variable "aws_region" {
  type        = string
  description = "aws_region"
}

variable "group" {
  type        = string
  description = "name of users group"
}

variable "users" {
  type        = list(string)
  description = "list of user names"
}