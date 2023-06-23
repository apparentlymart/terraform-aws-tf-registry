locals {
  domain_name ="my-domain.com."
  registry_domain_name = "registry.my-domain.com"
}


data "aws_route53_zone" "selected" {
  name = local.domain_name
}

data "aws_acm_certificate" "issued" {
  domain   = trimsuffix(local.domain_name, ".")
  statuses = ["ISSUED"]
}


module "registry" {
  source      = "../..//"
  name_prefix = "registry"

  dynamodb_store_capacity = {
    billing_mode = "PROVISIONNED"
    read = 5
    write = 1
  }

  friendly_hostname = {
    host                = local.registry_domain_name
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
  }

  tags = {
    Origin: "terraform"
    Billing: "Devops"
  }
}


resource "aws_route53_record" "registry" {
  zone_id = data.aws_route53_zone.selected.zone_id

  name = "${local.registry_domain_name}."
  type = "A"
  alias {
    name                   = module.registry_sregistryervice.dns_alias.hostname
    zone_id                = module.registry.dns_alias.route53_zone_id
    evaluate_target_health = true
  }
}