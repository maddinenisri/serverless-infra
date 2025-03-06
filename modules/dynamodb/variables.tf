variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for DynamoDB resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enable_stream" {
  description = "Whether to enable DynamoDB streams"
  type        = bool
  default     = false
}
