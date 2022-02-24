# Provider configuration 
provider "aws" {
  region  = "us-east-1"
}

# VPC configuration
resource "aws_vpc" "first_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "first_vpc"
  }  
}

# Public subnet
resource "aws_subnet" "public-1" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public-1 | first_vpc"
  }
}

# Private subnet
resource "aws_subnet" "private-1" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-1 | first_vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "first_vpc_gw" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "first_vpc_IGW | first_vpc"
  }
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
    Name = "public-rt | first_vpc"
  }
}

# Route table for Private-1 subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.first_vpc.id
  
  tags = {
    Name = "private-rt | first_vpc"
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

  ingress {
    description = "Allow the ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH | first_vpc"
  }
}

# Key pair 
resource "aws_key_pair" "ec2-key-pair" {
  key_name   = "ec2-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkNpCMPAVoDEUkOzC9n743n5pB9SXpIJacrFvSLWUoGa2T32SooRwM0n+DQZ1eXY3Ge+KKcXHm5UzvLuP+mc6z9fgpG95y7oSEhXTYu30aYrbFIjM83zVThSyFHz+bu+pKNospmJJ5QhuSknybIJUCrTq0EV7i7IwdOy7qWS/A4XLQKdSzzJ3v1m+yhyntECmUgR+afbpebN/jCwUVtKwd11YWdRf8C7fLOpsGPbSRwmMafXex2G/HJ4VgmML0cbS7ZjiscaLOYff6JJlEfxWMLmwxgZruntI0A7avXBUGVc3slLNn6KA2AiiZr2WAyqEKFSrq3F6skTnlmGGBFIbck4h+I5zw6LbZnJP53v3/rIZ+8Z6a0m8jujh4jXt8rofeLNbSp9pBqs0avP57BMbM68DLRDLLB6iFKl5l99YQNsLlwUI+aGQE7g35MD6M8QiUczxOZOBWVd/sKxQQ178tPEjtyLKRnDmCTLMTN5XyIEj6WmKaQwIBvM9AjyxDwO8= amjed@pop-os"
}

# Public EC2
resource "aws_instance" "public-ec2" {
  ami = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.public-1.id
  key_name = aws_key_pair.ec2-key-pair.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Public instance"
  }
}

# Private EC2
resource "aws_instance" "private-ec2" {
  ami = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  subnet_id = aws_subnet.private-1.id
  key_name = aws_key_pair.ec2-key-pair.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Private instance"
  }
}

