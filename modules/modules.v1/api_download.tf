resource "aws_api_gateway_method" "download_GET" {
  rest_api_id = aws_api_gateway_resource.download.rest_api_id
  resource_id = aws_api_gateway_resource.download.id
  http_method = "GET"

  authorization = local.authorizer.mode
  authorizer_id = local.authorizer.id
}

resource "aws_api_gateway_integration" "download_GET" {
  rest_api_id = aws_api_gateway_method.download_GET.rest_api_id
  resource_id = aws_api_gateway_method.download_GET.resource_id
  http_method = aws_api_gateway_method.download_GET.http_method

  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:dynamodb:action/GetItem"
  integration_http_method = "POST"
  credentials             = var.dynamodb_query_role_arn

  request_templates = {
    "application/json" = jsonencode({
      TableName = var.dynamodb_table_name
      Key : {
        Id      = { S = "$util.urlEncode($input.params('namespace'))/$util.urlEncode($input.params('module'))/$util.urlEncode($input.params('provider'))" }
        Version = { S = "$util.urlEncode($input.params('version'))" }
      }
    })
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
    "application/json" = <<EOT
#set($inputRoot = $input.path('$'))
{
  "version": "$util.escapeJavaScript($inputRoot.Item.Version.S)",
  "source": "$util.escapeJavaScript($inputRoot.Item.Source.S)",
}
EOT
  }
}
