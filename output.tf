
output "services" {
  description = "A service discovery configuration map for the deployed services. A JSON-serialized version of this should be published at /.well-known/terraform.json on an HTTPS server running at the friendly hostname for this registry."
  value       = module.registry.services
}

output "dns_alias" {
  description = "If the friendly_hostname input variable is set, this exports the hostname and Route53 zone id that should be used to point the friendly hostname at the registry API. If not using Route53 for DNS, you can alternatively create a regular CNAME record to the returned hostname. If friendly hostname is not enabled then this output is always null."
  value       = module.registry.dns_alias
}

output "rest_api_id" {
  description = "The id of the API Gateway REST API managed by this module."
  value       = module.registry.rest_api_id
}

output "rest_api_stage_name" {
  description = "The id of the API Gateway deployment stage managed by this module."
  value       = module.registry.rest_api_stage_name
}

output "registry_secret_key_name" {
  value       = module.jwt.name
  description = "JWT secret key name in aws secret manager"
}

output "dynamodb_table_name" {
  value       = module.store.dynamodb_table_name
  description = "Dynamodb table name"
}

output "dynamodb_table_arn" {
  value       = module.store.dynamodb_table_arn
  description = "Dynamodb table arn"
}


output "bucket_name" {
  value = module.store.bucket_name
}

output "bucket_arn" {
  value = module.store.bucket_arn
}
