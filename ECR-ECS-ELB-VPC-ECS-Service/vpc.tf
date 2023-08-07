# Includes private ECR (Elastic Container Registry) code

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

# Internet Access -> IGW ->  Route Table -> Subnets

resource "aws_vpc" "my_vpc_tf" {
  # This is the whole bloc for my network
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC test"
  }
}

resource "aws_subnet" "public_subnet_a" {
  availability_zone = var.region_az_1
  vpc_id            = aws_vpc.my_vpc_tf.id
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  availability_zone = var.region_az_2
  vpc_id            = aws_vpc.my_vpc_tf.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "Public Subnet B"
  }
}

resource "aws_subnet" "public_subnet_c" {
  availability_zone = var.region_az_3
  vpc_id            = aws_vpc.my_vpc_tf.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "Public Subnet C"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc_tf.id
  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.my_vpc_tf.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Public Subnet Route Table"
    }
}

resource "aws_route_table_association" "route_table_association1" {
    subnet_id      = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association2" {
    subnet_id      = aws_subnet.public_subnet_b.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association3" {
    subnet_id      = aws_subnet.public_subnet_c.id
    route_table_id = aws_route_table.route_table.id
}