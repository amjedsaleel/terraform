variable "vpc_name" {
  type    = string
  default = "first_vpc"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  type = map(any)
  default = {
    "name"                    = "Public-1"
    "cidir_block"             = "10.0.1.0/24"
    "availability_zone"       = "us-east-1a"
    "map_public_ip_on_launch" = true
  }
}

variable "private_subnet" {
  type = map(any)
  default = {
    "name"              = "Private-1"
    "cidir_block"       = "10.0.2.0/24"
    "availability_zone" = "us-east-1a"
  }
}

variable "inbound_traffic" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))

  default = [
    {
      description      = "Allow the traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}

variable "outbound_traffic" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))

  default = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}

variable "public_key_pair" {
  type = map(any)
  default = {
    "key_name"   = "public"
    "public_key" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkNpCMPAVoDEUkOzC9n743n5pB9SXpIJacrFvSLWUoGa2T32SooRwM0n+DQZ1eXY3Ge+KKcXHm5UzvLuP+mc6z9fgpG95y7oSEhXTYu30aYrbFIjM83zVThSyFHz+bu+pKNospmJJ5QhuSknybIJUCrTq0EV7i7IwdOy7qWS/A4XLQKdSzzJ3v1m+yhyntECmUgR+afbpebN/jCwUVtKwd11YWdRf8C7fLOpsGPbSRwmMafXex2G/HJ4VgmML0cbS7ZjiscaLOYff6JJlEfxWMLmwxgZruntI0A7avXBUGVc3slLNn6KA2AiiZr2WAyqEKFSrq3F6skTnlmGGBFIbck4h+I5zw6LbZnJP53v3/rIZ+8Z6a0m8jujh4jXt8rofeLNbSp9pBqs0avP57BMbM68DLRDLLB6iFKl5l99YQNsLlwUI+aGQE7g35MD6M8QiUczxOZOBWVd/sKxQQ178tPEjtyLKRnDmCTLMTN5XyIEj6WmKaQwIBvM9AjyxDwO8= amjed@pop-os"
  }
}

variable "private_key_pair" {
  type = map(any)
  default = {
    "key_name"   = "private"
    "public_key" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkNpCMPAVoDEUkOzC9n743n5pB9SXpIJacrFvSLWUoGa2T32SooRwM0n+DQZ1eXY3Ge+KKcXHm5UzvLuP+mc6z9fgpG95y7oSEhXTYu30aYrbFIjM83zVThSyFHz+bu+pKNospmJJ5QhuSknybIJUCrTq0EV7i7IwdOy7qWS/A4XLQKdSzzJ3v1m+yhyntECmUgR+afbpebN/jCwUVtKwd11YWdRf8C7fLOpsGPbSRwmMafXex2G/HJ4VgmML0cbS7ZjiscaLOYff6JJlEfxWMLmwxgZruntI0A7avXBUGVc3slLNn6KA2AiiZr2WAyqEKFSrq3F6skTnlmGGBFIbck4h+I5zw6LbZnJP53v3/rIZ+8Z6a0m8jujh4jXt8rofeLNbSp9pBqs0avP57BMbM68DLRDLLB6iFKl5l99YQNsLlwUI+aGQE7g35MD6M8QiUczxOZOBWVd/sKxQQ178tPEjtyLKRnDmCTLMTN5XyIEj6WmKaQwIBvM9AjyxDwO8= amjed@pop-os"
  }
}

variable "ec2_instance" {
  type = map(any)
  default = {
    "ami"                         = "ami-04505e74c0741db8d"
    "instance_type"               = "t2.micro"
    "availability_zone"           = "us-east-1a"
    "associate_public_ip_address" = true
  }
}