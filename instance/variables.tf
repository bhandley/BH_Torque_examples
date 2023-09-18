
variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "sandboxID" {
  type    = string
  default = "fonseca"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "ami" {
  type    = string
  default = "ami-0ccabb5f82d4c9af5"
}

variable "sg" {
  type    = string
  default = "sg-0712afd4461b7d61f"
}

variable "key_name" {
  type = string
  default = ""
}

variable "subnet_id" {
  type = string
  default = ""
}