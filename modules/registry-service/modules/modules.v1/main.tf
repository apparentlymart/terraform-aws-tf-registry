
data "aws_api_gateway_resource" "root" {
  rest_api_id = var.rest_api_id
  path        = "/"
}

resource "aws_api_gateway_resource" "modules_root" {
  rest_api_id = data.aws_api_gateway_resource.root.rest_api_id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "modules.v1"
}


resource "aws_api_gateway_resource" "namespace" {
  rest_api_id = aws_api_gateway_resource.modules_root.rest_api_id
  parent_id   = aws_api_gateway_resource.modules_root.id
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

resource "aws_api_gateway_resource" "versions" {
  rest_api_id = aws_api_gateway_resource.provider.rest_api_id
  parent_id   = aws_api_gateway_resource.provider.id
  path_part   = "versions"
}

resource "aws_api_gateway_resource" "version" {
  rest_api_id = aws_api_gateway_resource.provider.rest_api_id
  parent_id   = aws_api_gateway_resource.provider.id
  path_part   = "{version}"
}

resource "aws_api_gateway_resource" "download" {
  rest_api_id = aws_api_gateway_resource.version.rest_api_id
  parent_id   = aws_api_gateway_resource.version.id
  path_part   = "download"
}
