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
  authorizer_credentials = aws_iam_role.auth[count.index].arn
  identity_source        = "method.request.header.Authorization"

  depends_on = [aws_iam_role_policy.auth]
}
