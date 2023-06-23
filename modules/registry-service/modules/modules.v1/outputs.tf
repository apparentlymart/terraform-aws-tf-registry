
output "parent_resource_id" {
  value = var.rest_api_id
}


output "rest_api_id" {
  value = aws_api_gateway_resource.modules_root.id
}


output "rest_api_path" {
  value = aws_api_gateway_resource.modules_root.path
}

  