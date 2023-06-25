variable "rest_api_id" {
  type        = string
  description = "The id of the API Gateway REST API where a discovery document will be added."
}

variable "bucket_name" {
  type = string
}

variable "credentials_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use when querying the DynamoDB table given in dynamodb_table_name. This role must have at least full read-only access to the table contents."
}

variable "custom_authorizer_id" {
  type        = string
  description = "ID for optional API Gateway custom authorizer to apply to all of the API methods. If not set, the API methods do not require authorization."
  default     = null
}
