variable "name_prefix" {
  type        = string
}

variable "tags" {
  type        = map(string)
}

variable "storage" {
  type = object({
    dynamodb = object({ 
      name = optional(string, null)
      billing_mode = optional(string, "PAY_PER_REQUEST")
      read         = optional(number, 1)
      write        = optional(number, 1)
    })
    bucket = object({ 
      name = optional(string, null)
    })
  })
}