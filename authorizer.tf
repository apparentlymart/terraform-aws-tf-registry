data "aws_lambda_function" "auth" {
  count = length(local.authorizers)

  function_name = local.authorizers[count.index].function_name
}

resource "aws_api_gateway_authorizer" "main" {
  count = length(local.authorizers)

  rest_api_id = aws_api_gateway_rest_api.root.id
  name        = "custom"

  type                   = local.authorizers[count.index].type
  authorizer_uri         = data.aws_lambda_function.auth[count.index].invoke_arn
  authorizer_credentials = local.authorizers[count.index].invoke_role_arn
  identity_source        = "method.request.header.Authorization"
}
