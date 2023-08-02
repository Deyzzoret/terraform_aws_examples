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


resource "aws_instance" "ec2_instance" {
	ami           = var.ami_id # Ubuntu 22.04
	instance_type = "t2.micro"

	tags = {
		Name = "Basic EC2 instance"
	}

}