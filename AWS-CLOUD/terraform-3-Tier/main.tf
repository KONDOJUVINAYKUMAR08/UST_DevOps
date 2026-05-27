resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.project_name}-${var.environment}-vpc"
        Environment = var.environment 
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.project_name}-${var.environment}-igw"
        Environment = var.environment
    }
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-${var.environment}-public-subnet-${count.index+1}"
        Type = "Public"
    }
}

resource "aws_subnet" "web" {
    count = length(var.web_subnet_cidrs)
    vpc_id = aws_vpc.this.id
    cidr_block = var.web_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.project_name}-${var.environment}-web-subnet-${count.index+1}"
        Type = "Web-Private"
    }
}

resource "aws_subnet" "app" {
    count = length(var.app_subnet_cidrs)
    vpc_id = aws_vpc.this.id
    cidr_block = var.app_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.project_name}-${var.environment}-app-subnet-${count.index+1}"
        Type = "App-Private"
    }
}

resource "aws_subnet" "db" {
    count = length(var.db_subnet_cidrs)
    vpc_id = aws_vpc.this.id
    cidr_block = var.db_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.project_name}-${var.environment}-db-subnet-${count.index+1}"
        Type = "DB-Private"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)

    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    count = length(aws_subnet.public)

    domain = "vpc"

    tags = {
        Name = "${var.project_name}-${var.environment}-eip-${count.index+1}"
    }
}

resource "aws_nat_gateway" "this" {
    count = length(aws_subnet.public)

    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

    tags = {
        Name = "${var.project_name}-${var.environment}-nat-${count.index+1}"
    }
    depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.this)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "web" {
  count = length(aws_subnet.web)

  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}