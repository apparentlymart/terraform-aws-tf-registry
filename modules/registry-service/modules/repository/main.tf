
data "aws_api_gateway_resource" "root" {
  rest_api_id = var.rest_api_id
  path        = "/"
}

resource "aws_api_gateway_resource" "files" {
  rest_api_id = data.aws_api_gateway_resource.root.rest_api_id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "namespace" {
  rest_api_id = aws_api_gateway_resource.files.rest_api_id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "{namespace}"
}

resource "aws_api_gateway_resource" "module" {
  rest_api_id = aws_api_gateway_resource.namespace.rest_api_id
  parent_id   = aws_api_gateway_resource.namespace.id
  path_part   = "{module}"
}

resource "aws_api_gateway_resource" "provider" {
  rest_api_id = aws_api_gateway_resource.module.rest_api_id
  parent_id   = aws_api_gateway_resource.module.id
  path_part   = "{provider}"
}

resource "aws_api_gateway_resource" "version" {
  rest_api_id = aws_api_gateway_resource.provider.rest_api_id
  parent_id   = aws_api_gateway_resource.provider.id
  path_part   = "{version}"
}
