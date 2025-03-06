output "function_names" {
  description = "Names of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.function_name }
}

output "function_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "invoke_arns" {
  description = "Invoke ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
}
