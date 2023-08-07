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


variable "region_az_1" {
  description = "First AZ for us-east-1"
  type        = string
  default     = "us-east-1a"

}

variable "region_az_2" {
  description = "Second AZ for us-east-1"
  type        = string
  default     = "us-east-1b"

}

variable "region_az_3" {
  description = "Third AZ for us-east-1"
  type        = string
  default     = "us-east-1c"

}

