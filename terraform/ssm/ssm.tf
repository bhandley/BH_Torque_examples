
provider "aws" {
  region  = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">3.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "name" {
  type    = string
  default = "test_name"
}

variable "value" {
  type    = string
  default = "test_value"
  sensitive = true
}

resource "aws_ssm_parameter" "se_exercise_ssm_parameter" {
  name  = "${var.name}"
  type  = "String"
  value = "${var.value}"
}

output "ssm_parameter_name"  {
  value = aws_ssm_parameter.se_exercise_ssm_parameter.name
}

output "ssm_parameter_value" {
  value = aws_ssm_parameter.se_exercise_ssm_parameter.value
  sensitive = true
}

