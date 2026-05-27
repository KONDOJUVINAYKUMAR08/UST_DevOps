output "vpc_id" {
    description = "VPC_ID"
    value = aws_vpc.this.id
}

output "vpc_cidr" {
    value =  aws_vpc.this.cidr_block
}

output "public_subnet_id" {
    value = aws_subnet.public.id
}

output "private_subnet_id" {
    value = aws_subnet.private.id
}

output "internet_gateway_id" {
    value = aws_internet_gateway.this.id
}