# This block specifies the required Terraform providers and their versions.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # The source of the AWS provider plugin
      version = "~> 4.16"        # Specifies a version constraint for the provider (minimum version required)
    }
  }

  required_version = ">=0.13.1"   # Specifies the minimum Terraform version required to run this configuration.
}

# provider "aws" block
provider "aws" {
	region = var.region # The AWS region to which the resources will be deployed.
}


resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_eu-west-3a_public" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
    tags = {
        Name = "Public Subnet Route Table"
    }
}
resource "aws_route_table_association" "my_vpc_eu-west-3a_public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_eu-west-3a_public.id
}

locals {
   ingress_rules = [{
      port        = 22
      description = "Ingress rules for port SSH"
   },
   {
      port        = 80
      description = "Ingress rules for port HTTP"
   },
   {
      port        = 443
      description = "Ingress rules for port HTTPS"
   }]
}

resource "aws_security_group" "main" {
   name        = "resource_with_dynamic_block"
   description = "Allow SSH inbound connections"
   vpc_id      =  aws_vpc.my_vpc.id 

   dynamic "ingress" {
      for_each = local.ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
   }

   tags = {
      Name = "AWS security group dynamic block"
   }
}

resource "aws_instance" "ubuntu2204" {
  ami                         = var.ami_id # Ubuntu 22.04
  instance_type               = "t2.micro"
  key_name                    = "testkey"
  vpc_security_group_ids      = [aws_security_group.main.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  tags = {
    Name = "EC2 Ubuntu 22.04"
  }
}

output "instance_ubuntu2204_public_ip" {
  value = "${aws_instance.ubuntu2204.public_ip}"
}