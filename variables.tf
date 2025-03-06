variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "serverless-app"
}

variable "default_tags" {
  description = "Default tags for AWS resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "serverless-app"
    ManagedBy   = "terraform"
  }
}
