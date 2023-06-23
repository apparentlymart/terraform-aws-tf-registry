
resource "aws_api_gateway_domain_name" "main" {
  count = local.hostname_enabled ? 1 : 0

  domain_name              = local.friendly_hostname.host
  regional_certificate_arn = local.friendly_hostname.acm_certificate_arn
  security_policy          = var.domain_security_policy
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

resource "aws_api_gateway_base_path_mapping" "main" {
  count       = length(aws_api_gateway_domain_name.main)
  api_id      = aws_api_gateway_deployment.live.rest_api_id
  stage_name  = aws_api_gateway_deployment.live.stage_name
  domain_name = aws_api_gateway_domain_name.main[count.index].domain_name
}
