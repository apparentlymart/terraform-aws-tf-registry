variable "friendly_hostname" {
  description = "Configures a \"friendly hostname\" that will be used to reference objects in this registry. If this is set, the given hostname and certificate will be registered against the created API. Can be left unset if the service discovery information will be separately published at the friendly hostname, using the \"services\" output value."

  type = object({
    host                = string
    acm_certificate_arn = string
  })
  default = null
}

variable "name_prefix" {
  type        = "string"
  default     = "TerraformRegistry"
  description = "A name to use as the prefix for the created API Gateway REST API, DynamoDB tables, etc"
}

variable "lambda_authorizer" {
  description = "Configures a custom authorizer to use to control access to the registry API with a given Lambda function."

  type = object({
    type            = string
    function_name   = string
    invoke_role_arn = string
  })
  default = null
}

locals {
  name_prefix = var.name_prefix

  api_gateway_name   = local.name_prefix
  modules_table_name = "${local.name_prefix}-modules"

  authorizers = var.lambda_authorizer != null ? [var.lambda_authorizer] : []
}
