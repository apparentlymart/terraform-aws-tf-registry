locals {
  root_domain_name     = "my-domain.com"
  registry_domain_name = "registry.${local.root_domain_name}"
}


data "aws_route53_zone" "selected" {
  name = local.root_domain_name
}

# create ACME Certificat

resource "aws_acm_certificate" "certificate" {
  domain_name       = local.registry_domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
# create DNS record for validate
resource "aws_route53_record" "certificate" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.selected.zone_id
  ttl             = 60
}

# Validate certificat
resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate.fqdn]
}


module "registry" {
  source      = "../..//"
  name_prefix = "registry"

  storage = {
    dynamodb = {
      name : "my-domain-registry-tfe"
      billing_mode : "PROVISIONED"
      read : 5
      write : 1
    }
    bucket = {
      name : "my-domain-registry-tfe"
    }
  }

  friendly_hostname = {
    host                = local.registry_domain_name
    acm_certificate_arn = aws_acm_certificate.certificate.arn
  }

  tags = {
    Product : "Registry"
    ProductComponent : "terraform"
  }

  depends_on = [aws_acm_certificate.certificate]
}


resource "aws_route53_record" "registry" {
  zone_id = data.aws_route53_zone.selected.zone_id

  name = "${local.registry_domain_name}."
  type = "A"
  alias {
    name                   = module.registry.dns_alias.hostname
    zone_id                = module.registry.dns_alias.route53_zone_id
    evaluate_target_health = true
  }

  depends_on = [module.registry]
}

