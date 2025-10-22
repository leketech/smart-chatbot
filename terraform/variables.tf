# Input variables for smart chatbot infrastructure

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "smart-chatbot"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "log_level" {
  description = "Logging level"
  type        = string
  default     = "INFO"
}