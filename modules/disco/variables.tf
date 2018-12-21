variable "rest_api_id" {
  type        = string
  description = "The id of the API Gateway REST API where a discovery document will be added."
}

variable "services" {
  type        = map(string)
  description = "Map from service ids (like \"modules.v1\") to the URL where each service is rooted."
}
