# Terraform VPC Module

This repository contains a simple Terraform module to create an AWS VPC with the following resources:

- VPC with DNS support
- Internet Gateway for public access
- Public subnets
- Web, App, and DB private subnets
- NAT Gateways for outbound access from private subnets
- Public and private route tables

## Example Usage

```hcl
module "vpc" {
  source = "./"

  project_name        = "my-project"
  environment         = "dev"
  aws_region          = "us-east-1"
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  web_subnet_cidrs    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  app_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  db_subnet_cidrs     = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}
```

## Input Variables

- `project_name`: Name prefix for AWS resource tags.
- `environment`: Deployment environment tag (for example `dev`, `stg`, `prod`).
- `aws_region`: AWS region where the VPC will be created.
- `vpc_cidr`: CIDR block for the VPC.
- `availability_zones`: List of availability zones used by the subnets.
- `public_subnet_cidrs`: CIDR blocks for public subnets.
- `web_subnet_cidrs`: CIDR blocks for web private subnets.
- `app_subnet_cidrs`: CIDR blocks for application private subnets.
- `db_subnet_cidrs`: CIDR blocks for database private subnets.

## Notes

- Each public subnet is associated with the public route table and gets a NAT gateway for private subnet outbound traffic.
- The module currently does not expose any outputs in `outputs.tf`, so you may add outputs as needed for your environment.
