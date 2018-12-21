output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = var.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The full ARN for the DynamoDB table."
  value       = aws_dynamodb_table.modules.arn
}
