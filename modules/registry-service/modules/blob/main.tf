data "aws_api_gateway_resource" "root" {
  rest_api_id = var.rest_api_id
  path        = "/"
}


resource "aws_api_gateway_resource" "modules_root" {
  rest_api_id = data.aws_api_gateway_resource.root.rest_api_id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "blob"
}

resource "aws_api_gateway_resource" "object_path" {
  rest_api_id = aws_api_gateway_resource.modules_root.rest_api_id
  parent_id   = aws_api_gateway_resource.modules_root.id
  path_part   = "{object_path+}"
}


resource "aws_api_gateway_method" "object_get" {
  rest_api_id = data.aws_api_gateway_resource.root.rest_api_id
  resource_id = aws_api_gateway_resource.object_path.id

  http_method = "GET"

  authorization = local.authorizer.mode
  authorizer_id = local.authorizer.id

  request_parameters = {
    "method.request.path.object_path" : true
  }
  operation_name = "read_data_from_s3"
}

resource "aws_api_gateway_integration" "object_get" {
  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id

  http_method             = aws_api_gateway_method.object_get.http_method
  integration_http_method = aws_api_gateway_method.object_get.http_method

  type        = "AWS"
  uri         = "arn:aws:apigateway:${local.region_name}:s3:path/${var.bucket_name}/{object_path}"
  credentials = var.credentials_role_arn

  request_parameters = {
    "integration.request.path.object_path" : "method.request.path.object_path"
  }

}

resource "aws_api_gateway_method_response" "Status200" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_method_response" "Status400" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "Status500" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = "500"
}



resource "aws_api_gateway_integration_response" "Status200IntegrationResponse" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = aws_api_gateway_method_response.Status200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_integration_response" "Status400IntegrationResponse" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = aws_api_gateway_method_response.Status400.status_code

  selection_pattern = "4\\d{2}"
}

resource "aws_api_gateway_integration_response" "Status500IntegrationResponse" {
  depends_on = [aws_api_gateway_integration.object_get]

  rest_api_id = aws_api_gateway_method.object_get.rest_api_id
  resource_id = aws_api_gateway_method.object_get.resource_id
  http_method = aws_api_gateway_method.object_get.http_method
  status_code = aws_api_gateway_method_response.Status500.status_code

  selection_pattern = "5\\d{2}"
}