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
# Config AWS provider

provider "aws" {
	region = var.region # The AWS region to which the resources will be deployed.
}
# Create IAM Role for lambda
resource "aws_iam_role" "lambda_role_tf" {
 name   = "aws_lambda_role_tf"
#  In this step we are specifying which services/users
#  could implement this IAM role, therefore having the possibility to 
#  launch specified service
#  This means, it will be capable of using the described services
#  and the actions associated to the IAM
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for the lambda
# In this case, we define the actions the user assuming the IAM role will
# be capable of do
resource "aws_iam_policy" "iam_policy_for_lambda_tf" {

  name         = "aws_iam_policy_for_aws_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Role - Policy Attachment
# Previously we only defined the IAM role and the policy, now we are attaching
# the policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role_tf.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda_tf.arn
}

# Zipping the code
# Lambda needs  the code as zip file
# ${path.module}, makes reference to the current directoy
data "archive_file" "zip_the_python_code" {
 type        = "zip"
 source_dir  = "${path.module}/code/"
 output_path = "${path.module}/code/main.zip"
}

# Lambda Function, in terraform ${path.module} is the current directory.
resource "aws_lambda_function" "lambda_function_tf" {
# Here, we are given as paremeter the zip file 
 filename                       = "${path.module}/code/main.zip"
 # For our dashboard
 function_name                  = "Lambda-Function-Test"
 # Easier to specify the arn name, as it means AMAWZON RESOURCE NAMES
 # It shoudl be unique
 role                           = aws_iam_role.lambda_role_tf.arn
# Name of the function which will be executed, I would say that
# here is where our zipped code will get executed
 handler                        = "main.lambda_handler"
#  Specfiy the python version it should run
 runtime                        = "python3.8"
#  For this attribute, we define that the creation of this resource, depends on successful creation
#  of resources defined in the array
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

# With Lambda permission, API Gateway can invoke Lambda 
# Personally, I would say that this resource is needed so 
# lambda resource knows from where it can be invoked
# Or, which actions can be performed over it
resource "aws_lambda_permission" "apigw" {
 statement_id  = "AllowAPIGatewayInvoke"
 action        = "lambda:InvokeFunction"
 function_name = aws_lambda_function.lambda_function_tf.function_name
 principal     = "apigateway.amazonaws.com"
 # The "/*/*" portion grants access from any method on any resource within the API Gateway REST API.
 source_arn = "${aws_api_gateway_rest_api.rest_apigtw_tf.execution_arn}/*/*"
}