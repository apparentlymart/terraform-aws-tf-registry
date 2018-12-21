locals {
  hostname_enabled = var.friendly_hostname != null

  friendly_hostname          = local.hostname_enabled ? var.friendly_hostname : { host = "", acm_certificate_arn = "" }
  friendly_hostname_base_url = local.hostname_enabled ? "https://${local.friendly_hostname.host}" : ""
}

resource "aws_api_gateway_domain_name" "main" {
  count = local.hostname_enabled ? 1 : 0

  domain_name              = local.friendly_hostname.host
  regional_certificate_arn = local.friendly_hostname.acm_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "main" {
  count = length(aws_api_gateway_domain_name.main)

  api_id      = aws_api_gateway_deployment.live.rest_api_id
  stage_name  = aws_api_gateway_deployment.live.stage_name
  domain_name = aws_api_gateway_domain_name.main[count.index].domain_name
}
