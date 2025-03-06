variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for SQS resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}
