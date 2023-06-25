
locals {
  authorizer = var.custom_authorizer_id != null ? {
    mode = "CUSTOM"
    id   = var.custom_authorizer_id
    } : {
    mode = "NONE"
    id   = null
  }

  region_name = data.aws_region.region.name
}

data "aws_region" "region" {}