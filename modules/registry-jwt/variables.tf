
variable "secret_key_name" {
  type        = string
  description = "Optional AWS Secret name to store JWT secret"
}


variable "kms_key_id" {
  type        = string
  description = "custom kms key id (default aws/secretsmanager)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

