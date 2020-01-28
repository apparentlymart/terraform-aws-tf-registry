resource "aws_api_gateway_method" "download_GET" {
  rest_api_id = aws_api_gateway_resource.download.rest_api_id
  resource_id = aws_api_gateway_resource.download.id
  http_method = "GET"

  authorization = local.authorizer.mode
  authorizer_id = local.authorizer.id
}

data template_file "download_request" {
  template = file("${path.module}/files/download_request.tpl")
  vars = {
    dynamo_table_name = var.dynamodb_table_name
  }
}

resource "aws_api_gateway_integration" "download_GET" {
  rest_api_id = aws_api_gateway_method.download_GET.rest_api_id
  resource_id = aws_api_gateway_method.download_GET.resource_id
  http_method = aws_api_gateway_method.download_GET.http_method

  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.region.name}:dynamodb:action/GetItem"
  integration_http_method = "POST"
  credentials             = var.dynamodb_query_role_arn

  request_templates = {
    "application/json" = data.template_file.download_request.rendered
  }
}

resource "aws_api_gateway_method_response" "download_GET_200" {
  rest_api_id = aws_api_gateway_method.download_GET.rest_api_id
  resource_id = aws_api_gateway_method.download_GET.resource_id
  http_method = aws_api_gateway_method.download_GET.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.X-Terraform-Get" = true
  }
}

resource "aws_api_gateway_integration_response" "download_GET_200" {
  rest_api_id = aws_api_gateway_integration.download_GET.rest_api_id
  resource_id = aws_api_gateway_integration.download_GET.resource_id
  http_method = aws_api_gateway_integration.download_GET.http_method
  status_code = aws_api_gateway_method_response.download_GET_200.status_code

  response_parameters = {
    "method.response.header.X-Terraform-Get" = "integration.response.body.Item.Source.S"
  }

  response_templates = {
    "application/json" = file("${path.module}/files/download_response.template")
  }
}
