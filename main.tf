
locals {
  storage_name = "${var.name_prefix}-modules"
}

module "jwt" {
  source          = "./modules/registry-jwt"
  secret_key_name = var.secret_key_name != null ? var.secret_key_name : "${var.name_prefix}-jwt"
  kms_key_id      = var.kms_key_id
  tags            = var.tags

}

module "store" {
  source                  = "./modules/registry-store"
  name_prefix     = var.name_prefix
  storage = var.storage
  tags                    = var.tags
}


module "authorizer" {
  source          = "./modules/registry-authorizer"
  name_prefix     = var.name_prefix
  tags            = var.tags
  secret_key_name = module.jwt.name
  secret_key_arn  = module.jwt.arn

  depends_on = [
    module.jwt
  ]
}


module "registry" {
  source = "./modules/registry-service"

  name_prefix            = var.name_prefix
  friendly_hostname      = var.friendly_hostname
  api_type               = var.api_type
  api_access_policy      = var.api_access_policy
  domain_security_policy = var.domain_security_policy
  vpc_endpoint_ids       = var.vpc_endpoint_ids
  tags                   = var.tags

  lambda_authorizer = {
    type          = "TOKEN"
    function_name = module.authorizer.function_name
  }

  dynamodb_table_arn = module.store.dynamodb_table_arn
  dynamodb_table_name = module.store.dynamodb_table_name
  bucket_arn         = module.store.bucket_arn

  depends_on = [
    module.authorizer
  ]
}


resource "null_resource" "apigateway_create_deployment" {
  depends_on = [
    module.registry
  ]
  provisioner "local-exec" {
    command     = "aws apigateway create-deployment --rest-api-id ${module.registry.rest_api_id} --stage-name ${module.registry.rest_api_stage_name}"
    interpreter = ["/bin/bash", "-c"]
  }
}
