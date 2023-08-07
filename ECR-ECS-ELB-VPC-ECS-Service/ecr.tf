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

# Creating Elastic Container Repository for application
# We can see the push commands to this repository from the AWS console, i.e
# aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <UserID>.dkr.ecr.eu-central-1.amazonaws.com
# docker tag flask-app:latest <UserID>.ecr.eu-central-1.amazonaws.com/flask-app:latest
# docker push <UserID>.dkr.ecr.eu-central-1.amazonaws.com/flask-app:latest
resource "aws_ecr_repository" "flask_app_ecr_tf" {
  name = "flask-app-ecr"
}