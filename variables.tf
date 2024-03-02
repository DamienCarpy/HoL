variable "aws_region" {
  type        = string
  description = "aws_region"
}
variable "users" {
  type        = list(string)
  description = "list of users"
}