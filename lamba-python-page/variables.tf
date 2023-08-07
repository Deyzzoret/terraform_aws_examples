variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0cdccecaeef679568"

}


variable "stage_name" {
  description = "Stage name, used for API Gateway deployment"
  type        = string
  default     = "test"

}

variable "certificate_lambda_func_arn" {
  description = "ARN for cerficate associated to test lambda function"
  type        = string
  default     = "arn:aws:acm:us-east-1:103959727747:certificate/6e7a7666-60f9-4591-899b-6ff345b5c4b2"

}