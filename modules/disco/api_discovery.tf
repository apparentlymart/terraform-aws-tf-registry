
data "aws_api_gateway_resource" "root" {
  rest_api_id = var.rest_api_id
  path        = "/"
}

resource "aws_api_gateway_resource" "well_known" {
  rest_api_id = data.aws_api_gateway_resource.root.rest_api_id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = ".well-known"
}

resource "aws_api_gateway_resource" "well_known_terraform" {
  rest_api_id = aws_api_gateway_resource.well_known.rest_api_id
  parent_id   = aws_api_gateway_resource.well_known.id
  path_part   = "terraform.json"
}

resource "aws_api_gateway_method" "well_known_terraform_GET" {
  rest_api_id   = aws_api_gateway_resource.well_known_terraform.rest_api_id
  resource_id   = aws_api_gateway_resource.well_known_terraform.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "well_known_terraform_GET" {
  rest_api_id = aws_api_gateway_method.well_known_terraform_GET.rest_api_id
  resource_id = aws_api_gateway_method.well_known_terraform_GET.resource_id
  http_method = aws_api_gateway_method.well_known_terraform_GET.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "well_known_terraform_GET_200" {
  rest_api_id = aws_api_gateway_method.well_known_terraform_GET.rest_api_id
  resource_id = aws_api_gateway_method.well_known_terraform_GET.resource_id
  http_method = aws_api_gateway_method.well_known_terraform_GET.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "well_known_terraform_GET_200" {
  rest_api_id = aws_api_gateway_integration.well_known_terraform_GET.rest_api_id
  resource_id = aws_api_gateway_integration.well_known_terraform_GET.resource_id
  http_method = aws_api_gateway_integration.well_known_terraform_GET.http_method
  status_code = aws_api_gateway_method_response.well_known_terraform_GET_200.status_code

  response_templates = {
    "application/json" = jsonencode(var.services)
  }
}
