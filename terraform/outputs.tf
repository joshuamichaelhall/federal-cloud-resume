output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "website_url" {
  description = "URL of the deployed website"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitor"
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "deployment_instructions" {
  description = "Next steps after Terraform deployment"
  value = <<-EOT

    ========================================
    Deployment Complete!
    ========================================

    Website URL: https://${aws_cloudfront_distribution.website.domain_name}

    Next Steps:
    1. Update the API URL in frontend/script.js:
       const API_URL = '${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitor';

    2. Upload the frontend files to S3:
       aws s3 sync ../frontend s3://${aws_s3_bucket.website.id}/ --exclude ".DS_Store"

    3. Invalidate CloudFront cache:
       aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website.id} --paths "/*"

    4. Visit your website at:
       https://${aws_cloudfront_distribution.website.domain_name}

    ========================================
  EOT
}
