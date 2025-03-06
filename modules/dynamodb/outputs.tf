output "table_name" {
  description = "Name of the DynamoDB orders table"
  value       = aws_dynamodb_table.orders.name
}

output "table_arn" {
  description = "ARN of the DynamoDB orders table"
  value       = aws_dynamodb_table.orders.arn
}

output "stream_table_name" {
  description = "Name of the DynamoDB orders stream table"
  value       = var.enable_stream ? aws_dynamodb_table.orders_stream[0].name : null
}

output "stream_table_arn" {
  description = "ARN of the DynamoDB orders stream table"
  value       = var.enable_stream ? aws_dynamodb_table.orders_stream[0].arn : null
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream"
  value       = var.enable_stream ? aws_dynamodb_table.orders_stream[0].stream_arn : null
}
