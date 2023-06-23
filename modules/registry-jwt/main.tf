locals {
  kms_key_id = var.kms_key_id != null ? var.kms_key_id : data.aws_kms_alias.default_aws_secretmanager_key[0].target_key_id
}


data "aws_kms_alias" "default_aws_secretmanager_key" {
  count = var.kms_key_id == null ? 1 : 0
  name  = "alias/aws/secretsmanager"
}

resource "random_password" "secret" {
  length      = 256
  special     = false
  min_lower   = 16
  min_numeric = 16
  min_upper   = 16
}

resource "aws_secretsmanager_secret" "secret" {
  name       = var.secret_key_name
  kms_key_id = local.kms_key_id
  tags       = merge(var.tags, { Name : var.secret_key_name })
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = random_password.secret.result
}


