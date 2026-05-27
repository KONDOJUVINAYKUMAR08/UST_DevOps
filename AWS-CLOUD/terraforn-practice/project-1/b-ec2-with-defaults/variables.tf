variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-091138d0f0d41ff90"
}

variable "instance_name" {
  type    = string
  default = "EC2-with-Defaults"
}