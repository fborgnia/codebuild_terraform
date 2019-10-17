provider "aws" {
    region = "us-east-1"
    #profile = "saml"
} 

variable "name" {
  type = string
}

resource "aws_vpc" "default" {
  cidr_block       = "10.13.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "pipeline-${var.name}"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.13.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "pipeline-${var.name}-private-1a"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.13.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "pipeline-${var.name}-private-1b"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.13.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pipeline-${var.name}-public-1b"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "pipeline-${var.name}-private"
  }
}

resource "aws_route_table_association" "private-1a" {
  subnet_id      = "${aws_subnet.private_1a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-1b" {
  subnet_id      = "${aws_subnet.private_1b.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "pipeline-${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "pipeline-${var.name}-public"
  }
}

resource "aws_security_group" "default" {
  name        = "pipeline-${var.name}-default"
  description = "Allow TLS inbound http traffic to self for VPC endpoints and outbound for internet and Github enterprise on-prem connectivity."
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self = true
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.default.id}",
  ]

  subnet_ids = [
    "${aws_subnet.private_1a.id}",
    "${aws_subnet.private_1b.id}"
  ]

  private_dns_enabled = true
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "subnet_1a" {
  value = "${aws_subnet.private_1a.id}"
}
output "subnet_1b" {
  value = "${aws_subnet.private_1b.id}"
}
output "subnet_1a_arn" {
  value = "${aws_subnet.private_1a.arn}"
}
output "subnet_1b_arn" {
  value = "${aws_subnet.private_1b.arn}"
}
output "security_group_id" {
  value = "${aws_security_group.default.id}"
}