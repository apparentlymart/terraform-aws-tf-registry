

resource "aws_api_gateway_method" "version_GET" {
  rest_api_id = aws_api_gateway_resource.version.rest_api_id
  resource_id = aws_api_gateway_resource.version.id
  http_method = "GET"
}


resource "aws_api_gateway_integration" "version_GET" {
  rest_api_id = aws_api_gateway_method.version_GET.rest_api_id
  resource_id = aws_api_gateway_method.version_GET.resource_id
  http_method = aws_api_gateway_method.version_GET.http_method

  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.region.name}:s3:action/GetObject"
  integration_http_method = "GET"
  credentials             = var.credentials_role_arn

  request_parameters = {
    bucket = var.module_bucket_name
    object = "$util.urlEncode($input.params('namespace'))/$util.urlEncode($input.params('module'))/$util.urlEncode($input.params('provider'))/$util.urlEncode($input.params('version'))/archive.tar.gz"
  }
}
