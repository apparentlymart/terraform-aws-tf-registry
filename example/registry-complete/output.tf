

output "dynamodb_table_name" {
  value = module.registry.dynamodb_table_name
}

output "dynamodb_table_arn" {
  value = module.registry.dynamodb_table_arn
}

output "bucket_name" {
  value = module.registry.bucket_name
}

output "registry_secret_key_name" {
  value = module.registry.registry_secret_key_name
}

output "dns_alias" {
  value = module.registry.dns_alias
}

output "rest_api_stage_name" {
  value = module.registry.rest_api_stage_name
}

output "rest_api_id" {
  value = module.registry.rest_api_id
}

 