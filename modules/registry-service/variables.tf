variable "friendly_hostname" {
  type = object({
    host                = string
    acm_certificate_arn = string
  })
}

variable "name_prefix" {
  type = string
}

variable "lambda_authorizer" {
  type = object({
    type          = string
    function_name = string
  })
}

variable "api_type" {
  type = list(string)
}

variable "api_access_policy" {
  type = string
}

variable "domain_security_policy" {
  type = string
}

variable "vpc_endpoint_ids" {
  type = list(string)
}

variable "dynamodb_table_arn" {
  type = string

}

variable "bucket_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}

