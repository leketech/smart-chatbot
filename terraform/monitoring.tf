# CloudWatch monitoring for smart chatbot

# API Gateway Logs (referenced in main.tf)
# Note: This resource is created in main.tf as aws_cloudwatch_log_group.api_gateway_logs
# but we're adding an alarm for it here

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors chatbot lambda function errors"
  actions_enabled     = "true"

  dimensions = {
    FunctionName = "${var.project_name}-${var.environment}-handler"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  actions_enabled     = "true"

  dimensions = {
    ApiName = "${var.project_name}-${var.environment}-api"
    Stage   = var.environment
  }
}