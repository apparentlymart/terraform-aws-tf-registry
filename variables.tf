variable "friendly_hostname" {
  type        = "string"
  description = "The canonical \"friendly hostname\" that will be used to reference objects in this registry. If this is set, this hostname will be registered against the created API. Can be left unset if the service discovery information will be separately published at the friendly hostname, using the \"services\" output value."
  default     = ""
}

variable "name_prefix" {
  type        = "string"
  default     = "TerraformRegistry"
  description = "A name to use as the prefix for the created API Gateway REST API, DynamoDB tables, etc"
}

locals {
  name_prefix = var.name_prefix

  api_gateway_name   = local.name_prefix
  modules_table_name = "${local.name_prefix}-modules"
}
