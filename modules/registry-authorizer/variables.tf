
variable "secret_key_name" {
  type = string
}

variable "secret_key_arn" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Ressource tags"
}