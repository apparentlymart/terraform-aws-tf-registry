variable "name_prefix" {
  type        = string
  default     = "terraform-registry"
  description = "A name to use as the prefix for the created API Gateway REST API, DynamoDB tables, etc"
}


variable "friendly_hostname" {
  description = "Configures a \"friendly hostname\" that will be used to reference objects in this registry. If this is set, the given hostname and certificate will be registered against the created API. Can be left unset if the service discovery information will be separately published at the friendly hostname, using the \"services\" output value."

  type = object({
    host                = string
    acm_certificate_arn = string
  })
  default = null
}

variable "api_type" {
  description = "Sets API type if you want a private API without a custom domain name, defaults to EDGE for public access"
  default     = ["EDGE"]
  type        = list(string)
}

variable "api_access_policy" {
  description = "If using a Private API requires you to have an access policy configured and accepts a string, but must be valid json. Defaults to Null"
  type        = string
  default     = null
}

variable "domain_security_policy" {
  description = "Sets the TLS version to desired state, defaults to 1.2"
  type        = string
  default     = "TLS_1_2"
}

variable "vpc_endpoint_ids" {
  description = "Sets the VPC endpoint ID for a private API, defaults to null"
  type        = list(string)
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "storage" {
  type = object({
    dynamodb = object({
      name         = optional(string, null)
      billing_mode = optional(string, "PAY_PER_REQUEST")
      read         = optional(number, 1)
      write        = optional(number, 1)
    })
    bucket = object({
      name = optional(string, null)
    })
  })
  default = {
    dynamodb = {
      name         = null
      billing_mode = "PAY_PER_REQUEST"
      read         = 1
      write        = 1
    }
    bucket = {
      name = null
    }
  }
}


variable "secret_key_name" {
  type        = string
  description = "Optional AWS Secret name to store JWT secret"
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "Optional custom kms key id (default aws/secretsmanager)"
  default     = null
}