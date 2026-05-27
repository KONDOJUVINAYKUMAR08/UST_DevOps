output "vpc_id" {
    value = aws_vpc.my_vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.my_vpc.cidr_block
}

output "subnet_id" {
    value = aws_subnet.my_subnet.id
}

output "internet_gateway_id" {
    value = aws_internet_gateway.my_igw.id
}