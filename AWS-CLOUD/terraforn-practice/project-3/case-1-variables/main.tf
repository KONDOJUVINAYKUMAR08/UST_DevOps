terraform {
    required_providers {
        aws = {
            source = "registry.terraform.io/hashicorp/aws"
            version = "6.44.0"
        }
    }
}

provider "aws" {
    region = var.aws_region

}

variable "aws_region" {
    type = string
    default = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "demo-vpc"
    }
}