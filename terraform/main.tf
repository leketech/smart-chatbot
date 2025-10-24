terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket         = "smart-chatbot-terraform-state-907849381252"
    key            = "chatbot/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

######################
# Data sources
######################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

######################
# Archive Lambda function code
######################
data "archive_file" "lambda_zip" {
  type = "zip"
  # adjust source_dir if your lambda code is in a different location
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda_function.zip"
  excludes    = ["node_modules", "*.test.js", "coverage", ".eslintrc.json", "jest.config.js"]
}

######################
# IAM for Lambda
######################
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_cloudwatch" {
  name = "${var.project_name}-${var.environment}-lambda-cloudwatch"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_lex" {
  name = "${var.project_name}-${var.environment}-lambda-lex"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lex:RecognizeText",
          "lex:RecognizeUtterance"
        ]
        Resource = [
          "arn:aws:lex:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bot/${aws_lexv2models_bot.chatbot.id}:*",
          "arn:aws:lex:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bot-alias/${aws_lexv2models_bot.chatbot.id}/prod"
        ]
      }
    ]
  })
}

######################
# CloudWatch Log Groups
######################
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-handler"
  retention_in_days = var.log_retention_days

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}-api"
  retention_in_days = var.log_retention_days
}

######################
# Lambda Function
######################
resource "aws_lambda_function" "chatbot" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-handler"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      LOG_LEVEL        = var.log_level
      PROJECT          = var.project_name
      LEX_BOT_ID       = aws_lexv2models_bot.chatbot.id
      LEX_BOT_ALIAS_ID = "prod-${var.environment}"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.lambda_cloudwatch,
    aws_iam_role_policy.lambda_lex
  ]
}

######################
# Lambda permissions
######################
# Allow Lex to invoke the Lambda
resource "aws_lambda_permission" "lex_invoke" {
  statement_id  = "AllowLexInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "arn:aws:lex:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bot-alias/*"
}

# Allow API Gateway to invoke the Lambda (execution ARN wildcard for all stages/methods)
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatbot_api.execution_arn}/*/*"
}

######################
# IAM for Lex
######################
resource "aws_iam_role" "lex_role" {
  name = "${var.project_name}-${var.environment}-lex-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lexv2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lex_policy" {
  role       = aws_iam_role.lex_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexRunBotsOnly"
}

######################
# Lex Bot (Simplified)
######################
resource "aws_lexv2models_bot" "chatbot" {
  name                        = "SmartChatbotDevBot-${var.environment}"
  role_arn                    = aws_iam_role.lex_role.arn
  idle_session_ttl_in_seconds = 300

  data_privacy {
    child_directed = false
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lexv2models_bot_locale" "en_us" {
  bot_id      = aws_lexv2models_bot.chatbot.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  n_lu_intent_confidence_threshold = 0.40

  voice_settings {
    voice_id = "Joanna"
  }
}

resource "aws_lexv2models_intent" "greeting" {
  bot_id      = aws_lexv2models_bot.chatbot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en_us.locale_id
  name        = "CustomGreetingIntent"

  fulfillment_code_hook {
    enabled = false
  }

  sample_utterance {
    utterance = "hello"
  }
  sample_utterance {
    utterance = "hi"
  }
  sample_utterance {
    utterance = "hey"
  }
  sample_utterance {
    utterance = "good morning"
  }
  sample_utterance {
    utterance = "good afternoon"
  }
  sample_utterance {
    utterance = "greetings"
  }
}

resource "aws_lexv2models_intent" "help" {
  bot_id      = aws_lexv2models_bot.chatbot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en_us.locale_id
  name        = "CustomHelpIntent"

  fulfillment_code_hook {
    enabled = false
  }

  sample_utterance {
    utterance = "help"
  }
  sample_utterance {
    utterance = "what can you do"
  }
  sample_utterance {
    utterance = "what are your capabilities"
  }
  sample_utterance {
    utterance = "how do you work"
  }
  sample_utterance {
    utterance = "what can I ask"
  }
}

resource "aws_lexv2models_intent" "fallback" {
  bot_id      = aws_lexv2models_bot.chatbot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en_us.locale_id
  name        = "CustomFallbackIntent"

  fulfillment_code_hook {
    enabled = false
  }

  sample_utterance {
    utterance = "I don't know"
  }
  sample_utterance {
    utterance = "what is this"
  }
  sample_utterance {
    utterance = "can you explain"
  }
}

######################
# API Gateway REST API + resources + methods + integrations
######################
resource "aws_api_gateway_rest_api" "chatbot_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API Gateway for Chatbot Integration"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "chat" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "chat"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  resource_id   = aws_api_gateway_resource.chat.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  resource_id   = aws_api_gateway_resource.chat.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.chatbot_api.id
  resource_id             = aws_api_gateway_resource.chat.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.chatbot.invoke_arn
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_deployment" "chatbot" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.chat.id,
      aws_api_gateway_method.post.id,
      aws_api_gateway_method.options.id,
      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_integration.options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_stage" "chatbot" {
  deployment_id = aws_api_gateway_deployment.chatbot.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  stage_name    = var.environment

  xray_tracing_enabled = true

  # ensure log group exists before stage creation
  depends_on = [
    aws_api_gateway_deployment.chatbot,
    aws_cloudwatch_log_group.api_gateway_logs
  ]
}

