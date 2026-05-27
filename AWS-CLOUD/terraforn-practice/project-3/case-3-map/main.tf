terraform {
    required_providers {
        aws = {
            source = "registry.terraform.io/hashicorp/aws"
            version = "6.44.0"
        }
    }
}

provider "aws" {
    region = var.region
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "region_amis" {
    type = map(string)
    default = {
        "us-east-1" = "ami-091138d0f0d41ff90"
        "ap-south-1" = "ami-07a00cf47dbbc844c"
    }
}

variable "region_az" {
    type = map(string)
    default = {
        "us-east-1" = "us-east-1a"
        "ap-south-1" = "ap-south-1a"
    }
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
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = var.region_az[var.region]
    tags = {
        Name = "demo-subnet"
    }
}

resource "aws_instance" "main" {
    ami = var.region_amis[var.region]
    instance_type = "t2.micro"
    subnet_id = aws_subnet.main.id
}