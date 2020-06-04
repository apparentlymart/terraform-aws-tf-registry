# Terraform Modules API in API Gateway

This Terraform module is a building block that creates API Gateway resources
and methods (under a given pre-existing API) that together implement the
Terraform module registry API in terms of a given DynamoDB table.

```hcl
module "modules_v1" {
  source = "git@github.com:SwissArmyRonin/terraform-aws-tf-registry.git//modules/modules.v1"

  rest_api_id             = aws_api_gateway_rest_api.example.id
  parent_resource_id      = aws_api_gateway_rest_api.example.root_resource_id
  dynamodb_table_name     = module.modules_store.dynamodb_table_name
  dynamodb_query_role_arn = aws_iam_role.example.arn
}
```

The DynamoDB table is assumed to have a primary key of `Id`, `Version` and
generally behave like the table created by [the `module-store` module](../module-store).
The given `dynamodb_query_role_arn` is the role to use to query that table,
which must have at least access to perform `dynamodb:Query` and `dynamodb:GetItem`
against given table.

The above example shows creating the module API at the root of an existing
REST API, but a more likely configuration is to first create one sub-resource
with a name like `modules.v1` and pass its id as `parent_resource_id`, thus
leaving room for other services to be deployed alongside in future.

The base URL for the modules service (to publish in a discovery document) is
the full URL of the resource specified in `parent_resource_id`, with a trailing
slash.

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
| custom\_authorizer\_id | ID for optional API Gateway custom authorizer to apply to all of the API methods. If not set, the API methods do not require authorization. | `string` | `null` | no |
| dynamodb\_query\_role\_arn | The ARN of the IAM role to use when querying the DynamoDB table given in dynamodb\_table\_name. This role must have at least full read-only access to the table contents. | `string` | n/a | yes |
| dynamodb\_table\_name | The name of an already-existing DynamoDB table created by the sibling "modules-store" module. | `string` | n/a | yes |
| parent\_resource\_id | The id of the parent resource that will serve as the root of the modules service, which must belong to the REST API whose id is given in rest\_api\_id. | `string` | n/a | yes |
| region | An AWS region. | `string` | n/a | yes |
| rest\_api\_id | The id of the API Gateway REST API that contains the given parent\_resource\_id. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
