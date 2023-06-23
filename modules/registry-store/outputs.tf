output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = local.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The full ARN for the DynamoDB table."
  value       = aws_dynamodb_table.modules.arn
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}