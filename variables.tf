variable "friendly_hostname" {
  type        = "string"
  description = "The canonical \"friendly hostname\" that will be used to reference objects in this registry. If this isn't set, the default API Gateway hostname will be used."
  default     = ""
}

variable "name_prefix" {
  type        = "string"
  default     = "TerraformRegistry"
  description = "A name to use as the prefix for the created API Gateway REST API, DynamoDB tables, etc"
}

locals {
  api_gateway_name   = var.name_prefix
  modules_table_name = "${var.name_prefix}-modules"
}
