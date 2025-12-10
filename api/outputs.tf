output "api_gateway_url" {
  description = "Base URL for API Gateway stage"
  value       = aws_api_gateway_stage.api.invoke_url
}

output "custom_domain_url" {
  description = "Custom domain URL for the API"
  value       = "https://${aws_api_gateway_domain_name.api.domain_name}"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.api_lambda.arn
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}
