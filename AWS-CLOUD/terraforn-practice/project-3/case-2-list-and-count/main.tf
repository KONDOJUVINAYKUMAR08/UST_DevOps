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

variable "azs" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "demo-vpc"
    }
}

resource "aws_subnet" "main" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet("10.0.0.0/16", 4 , count.index)
    availability_zone = var.azs[count.index]
    tags = {
        Name = "demo-subnet"
    }
}