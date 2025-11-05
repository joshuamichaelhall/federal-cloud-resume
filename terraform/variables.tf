variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-resume"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for visitor counter"
  type        = string
  default     = "cloud-resume-visitors"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "cloud-resume-visitor-counter"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "cloud-resume-api"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for static website hosting (must be globally unique)"
  type        = string
  # You must provide this value or it will be generated with random suffix
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100" # Use only North America and Europe edge locations
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "CloudResume"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}
