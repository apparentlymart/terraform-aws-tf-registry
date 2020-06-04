# Terraform Modules API in API Gateway

Listen for GitHub webhooks on releases and update the registry.

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
| dynamodb\_table\_name | The name of an already-existing DynamoDB table created by the sibling "modules-store" module. | `string` | n/a | yes |
| dynamodb\_update\_role\_arn | The ARN of the IAM role to use when updating the DynamoDB table given in dynamodb\_table\_name. This role must have at least full put-item access to the table contents. | `string` | n/a | yes |
| parent\_resource\_id | The id of the parent resource that will serve as the root of the modules service, which must belong to the REST API whose id is given in rest\_api\_id. | `string` | n/a | yes |
| region | An AWS region. | `string` | n/a | yes |
| rest\_api\_id | The id of the API Gateway REST API that contains the given parent\_resource\_id. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
