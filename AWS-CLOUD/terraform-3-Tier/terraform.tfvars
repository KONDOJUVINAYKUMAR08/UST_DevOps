aws_region = "us-east-1"

project_name = "3-tier"

environment = "dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

web_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

app_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

db_subnet_cidrs = [
  "10.0.31.0/24",
  "10.0.32.0/24"
]