resource "aws_api_gateway_method" "versions_GET" {
  rest_api_id = aws_api_gateway_resource.versions.rest_api_id
  resource_id = aws_api_gateway_resource.versions.id
  http_method = "GET"

  authorization = local.authorizer.mode
  authorizer_id = local.authorizer.id
}

resource "aws_api_gateway_integration" "versions_GET" {
  rest_api_id = aws_api_gateway_method.versions_GET.rest_api_id
  resource_id = aws_api_gateway_method.versions_GET.resource_id
  http_method = aws_api_gateway_method.versions_GET.http_method

  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.region.name}:dynamodb:action/Query"
  integration_http_method = "POST"
  credentials             = var.dynamodb_query_role_arn

  request_templates = {
    "application/json" = jsonencode({
      TableName              = var.dynamodb_table_name,
      ScanIndexForward       = false,
      KeyConditionExpression = "Id = :v1"
      ExpressionAttributeValues = {
        ":v1" = { S = "$util.replaceAll($util.escapeJavaScript($input.params('namespace')))/$util.escapeJavaScript($input.params('module'))/$util.escapeJavaScript($input.params('provider'))" }
      }
    })
  }
}

resource "aws_api_gateway_method_response" "versions_GET_200" {
  rest_api_id = aws_api_gateway_method.versions_GET.rest_api_id
  resource_id = aws_api_gateway_method.versions_GET.resource_id
  http_method = aws_api_gateway_method.versions_GET.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "versions_GET_200" {
  rest_api_id = aws_api_gateway_integration.versions_GET.rest_api_id
  resource_id = aws_api_gateway_integration.versions_GET.resource_id
  http_method = aws_api_gateway_integration.versions_GET.http_method
  status_code = aws_api_gateway_method_response.versions_GET_200.status_code

  response_templates = {
    "application/json" = <<EOT
#set($inputRoot = $input.path('$'))
{
  "modules": [
    {
      "versions": [
#foreach($elem in $inputRoot.Items)        {
        "version": "$util.escapeJavaScript($elem.Version.S)"
      }#if($foreach.hasNext),#end

	#end
      ]
    }
  ]
}
EOT
  }
}
