variable "rest_api_id" {
  type        = string
  description = "The id of the API Gateway REST API that contains the given parent_resource_id."
}

variable "parent_resource_id" {
  type        = string
  description = "The id of the parent resource that will serve as the root of the modules service, which must belong to the REST API whose id is given in rest_api_id."
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name to use to establish a DynamoDB table that will contain the metadata for published modules."
}
