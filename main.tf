# Provider configuration 
provider "aws" {
  region  = "us-east-1"
}

# VPC configuration
resource "aws_vpc" "first_vpc" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }  
}

# Public subnet
resource "aws_subnet" "public-1" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = var.public_subnet["cidir_block"]
  availability_zone = var.public_subnet["availability_zone"]
  map_public_ip_on_launch = var.public_subnet["map_public_ip_on_launch"]

  tags = {
    Name = var.public_subnet["name"]
  }
}

# Private subnet
resource "aws_subnet" "private-1" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = var.private_subnet["cidir_block"]
  availability_zone = var.private_subnet["availability_zone"]

  tags = {
    Name = var.private_subnet["name"]
  }
}

# Internet gateway
resource "aws_internet_gateway" "first_vpc_gw" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "${var.vpc_name}_IGW" 
  }
}

# Elastic IP
resource "aws_eip" "nat_ip" {
}

# Nat gateway
resource "aws_nat_gateway" "first_vpc_nat" {
  subnet_id = aws_subnet.public-1.id
  allocation_id = aws_eip.nat_ip.id
  
  tags = {
    Name = "First vpc nat"
  }

  depends_on = [aws_internet_gateway.first_vpc_gw]
}

# Route table for Public-1 subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first_vpc_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.first_vpc_gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route table for Private-1 subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.first_vpc_nat.id
  }
  
  tags = {
    Name = "private-rt"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "public-rta" {
  subnet_id = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-rt.id
}

# Route table association with private subnets
resource "aws_route_table_association" "private-rta" {
  subnet_id =  aws_subnet.private-1.id
  route_table_id = aws_route_table.private-rt.id
}



# Security groups
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.first_vpc.id

  # Inbound traffic
  dynamic "ingress" {
    for_each = var.inbound_traffic
    content {
      description = ingress.value["description"]
      from_port = ingress.value["from_port"]
      to_port = ingress.value["to_port"]
      protocol = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
      ipv6_cidr_blocks = ingress.value["ipv6_cidr_blocks"]
    }
  }

  # Outbound trafic
  dynamic "egress" {
    for_each = var.outbound_traffic
    content {
      from_port = egress.value["from_port"]
      to_port = egress.value["to_port"]
      protocol = egress.value["protocol"]
      cidr_blocks = egress.value["cidr_blocks"]
      ipv6_cidr_blocks = egress.value["ipv6_cidr_blocks"]
    }
  }

  tags = {
    Name = "Security groups"
  }
}

# Key pair 
resource "aws_key_pair" "ec2-key-pair" {
  key_name   = var.ssh_key_pair["key_name"]
  public_key = var.ssh_key_pair["public_key"]
}

# Public EC2
resource "aws_instance" "public-ec2" {
  ami = var.ec2_instance["ami"]
  instance_type = var.ec2_instance["instance_type"]
  availability_zone = var.ec2_instance["availability_zone"]
  subnet_id = aws_subnet.public-1.id
  key_name = aws_key_pair.ec2-key-pair.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Public instance"
  }
}

# Private EC2
resource "aws_instance" "private-ec2" {
  ami = var.ec2_instance["ami"]
  instance_type = var.ec2_instance["instance_type"]
  availability_zone = var.ec2_instance["availability_zone"]
  associate_public_ip_address = var.ec2_instance["associate_public_ip_address"]
  subnet_id = aws_subnet.private-1.id
  key_name = aws_key_pair.ec2-key-pair.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Private instance"
  }
}

