resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.vpc_name}-vpc"
        Environment = var.environment

    }
 
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.availability_zone
    
    tags = {
        Name = "${var.vpc_name}-public-subnet"
        Environment = var.environment
        Type = "Public"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone

    tags = {
        Name = "${var.vpc_name}-private-subnet"
        Environment = var.environment
        Type = "Private"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.vpc_name}-igw"
        Environment = var.environment
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = "${var.vpc_name}-public-rt"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.vpc_name}-private-rt"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}