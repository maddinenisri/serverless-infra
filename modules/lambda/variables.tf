variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for Lambda functions"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to process"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the SQS queue for sending messages"
  type        = string
  default     = null # Optional to avoid breaking changes
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to store order data"
  type        = string
}

variable "lambda_role_dependency" {
  description = "Dependency to ensure IAM role exists before Lambda functions"
  type        = any
  default     = null
}
