resource "aws_api_gateway_rest_api" "root" {
  name = local.api_gateway_name
  endpoint_configuration {
    types            = var.api_type
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }
  policy = local.api_access_policy
  tags   = merge(var.tags, { Name : local.api_gateway_name })
}

module "modules_v1" {
  source = "./modules/modules.v1"

  rest_api_id          = aws_api_gateway_rest_api.root.id
  dynamodb_table_name  = var.dynamodb_table_name
  credentials_role_arn = aws_iam_role.modules.arn
  custom_authorizer_id = (
    length(aws_api_gateway_authorizer.main) > 0 ? aws_api_gateway_authorizer.main[0].id : null
  )
}

module "disco" {
  source = "./modules/disco"

  rest_api_id = aws_api_gateway_rest_api.root.id
  services = {
    "modules.v1" = "${module.modules_v1.rest_api_path}/",
  }
}


module "blob" {
  source = "./modules/blob"

  rest_api_id          = aws_api_gateway_rest_api.root.id
  bucket_name          = var.bucket_name
  credentials_role_arn = aws_iam_role.modules.arn
  custom_authorizer_id = (
    length(aws_api_gateway_authorizer.main) > 0 ? aws_api_gateway_authorizer.main[0].id : null
  )
}


resource "aws_api_gateway_deployment" "live" {
  depends_on = [
    module.modules_v1,
    module.disco,
    module.blob,
  ]
  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name  = "live"
  variables = {
    deployment_version = formatdate("MMDDYYYYHHmmss", timestamp())
    version_scheme     = "MMDDYYYHHmmss"
  }
  lifecycle {
    create_before_destroy = true
  }
}
