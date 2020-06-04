resource "aws_api_gateway_resource" "webhook" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "webhook_POST" {
  rest_api_id   = aws_api_gateway_resource.webhook.rest_api_id
  resource_id   = aws_api_gateway_resource.webhook.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "webhook_POST" {
  rest_api_id = aws_api_gateway_method.webhook_POST.rest_api_id
  resource_id = aws_api_gateway_method.webhook_POST.resource_id
  http_method = aws_api_gateway_method.webhook_POST.http_method

  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:dynamodb:action/PutItem"
  integration_http_method = "POST"
  credentials             = var.dynamodb_update_role_arn

  request_templates = {
    "application/json" = <<VELOCITY
#set($namespace = $input.path('$.repository.owner.login'))
#set($module = $input.path('$.repository.name'))
#set($version = $input.path('$.release.tag_name'))
{
  "TableName": "TerraformRegistry-modules",
  "Item": {
    "Id": { "S": "$namespace/$module/aws" },
    "Version": { "S": "$version" },
    "Source": { "S": "git@github.com:$namespace/$module.git?ref=$version" }
  }
}
VELOCITY
  }
}

resource "aws_api_gateway_method_response" "webhook_POST_200" {
  rest_api_id = aws_api_gateway_method.webhook_POST.rest_api_id
  resource_id = aws_api_gateway_method.webhook_POST.resource_id
  http_method = aws_api_gateway_method.webhook_POST.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "webhook_POST_200" {
  rest_api_id = aws_api_gateway_integration.webhook_POST.rest_api_id
  resource_id = aws_api_gateway_integration.webhook_POST.resource_id
  http_method = aws_api_gateway_integration.webhook_POST.http_method
  status_code = aws_api_gateway_method_response.webhook_POST_200.status_code

  response_templates = {
    "application/json" = "{}"
  }
}
