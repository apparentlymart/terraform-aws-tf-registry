variable "friendly_hostname" {
  description = "Configures a \"friendly hostname\" that will be used to reference objects in this registry. If this is set, the given hostname and certificate will be registered against the created API. Can be left unset if the service discovery information will be separately published at the friendly hostname, using the \"services\" output value."

  type = object({
    host                = string
    acm_certificate_arn = string
  })
  default = null
}

variable "name_prefix" {
  type        = string
  default     = "TerraformRegistry"
  description = "A name to use as the prefix for the created API Gateway REST API, DynamoDB tables, etc"
}

variable "lambda_authorizer" {
  description = "Configures a custom authorizer to use to control access to the registry API with a given Lambda function."

  type = object({
    type          = string
    function_name = string
  })
  default = null
}

variable "api_type" {
  description = "Sets API type if you want a private API without a custom domain name, defaults to EDGE for public access"
  default = ["EDGE"]
  type = list(string)
}

variable "api_access_policy" {
  description = "If using a Private API requires you to have an access policy configured and accepts a string, but must be valid json. Defaults to Null"
  type = string
}

variable "domain_security_policy" {
  description = "Sets the TLS version to desired state, defaults to 1.2"
  type = string
  default = "TLS_1_2"
}

variable "vpc_endpoint_ids" {
  description = "Sets the VPC endpoint ID for a private API, defaults to null"
  type = list(string)
  default = null
}

locals {
  name_prefix = var.name_prefix
  api_gateway_name   = local.name_prefix
  modules_table_name = "${local.name_prefix}-modules"
  authorizers = var.lambda_authorizer != null ? [var.lambda_authorizer] : []
  api_access_policy = var.api_type != "PRIVATE" ? var.api_access_policy : ""
  vpc_endpoint_id = var.vpc_endpoint_ids != null ? var.vpc_endpoint_ids : []
}
