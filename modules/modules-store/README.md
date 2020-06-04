# Modules Index in DynamoDB

This Terraform module is a building block that creates a DynamoDB table ready
to store items describing Terraform modules available for installation.

```hcl
module "modules_store" {
  source = "apparentlymart/tf-registry/aws//modules/modules-store"

  dynamodb_table_name = "any-name-you-like"
}
```

At present this module does not allow the DynamoDB table settings to be
customized, and forces provisioned capacity with only one unit of both read
and write capacity. This may become more configurable in a later release.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dynamodb\_table\_name | The name to use to establish a DynamoDB table that will contain the metadata for published modules. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dynamodb\_table\_arn | The full ARN for the DynamoDB table. |
| dynamodb\_table\_name | The name of the DynamoDB table. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
