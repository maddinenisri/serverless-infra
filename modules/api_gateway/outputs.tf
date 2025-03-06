output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_url" {
  description = "URL of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.name
}
