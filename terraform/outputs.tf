# Output values for smart chatbot infrastructure

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.chatbot.arn
}

output "api_endpoint_url" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.chatbot.invoke_url
}

output "lex_bot_id" {
  description = "ID of the Lex bot"
  value       = aws_lexv2models_bot.chatbot.id
}