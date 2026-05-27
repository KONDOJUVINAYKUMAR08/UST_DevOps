variable "ports" {
    default = [80, 443]
}

resource "aws_security_group" "web_sg" {
    name = "web-sg"

    dynamic "ingress" {
        for_each = var.ports

        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}