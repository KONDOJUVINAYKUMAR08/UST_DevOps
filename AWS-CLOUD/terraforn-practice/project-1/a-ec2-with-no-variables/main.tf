provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "simple_ec2" {
    ami = "ami-091138d0f0d41ff90"
    instance_type = "t2.micro"

    tags = {
        Name = "demo-1a"
    }
}