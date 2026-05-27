terraform {
    required_providers {
        aws = {
            source = "registry.terraform.io/hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

module "dev_vpc" {
    source = "../modules/vpc"

    vpc_name = "dev"
    vpc_cidr = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
    environment = "dev"
}
