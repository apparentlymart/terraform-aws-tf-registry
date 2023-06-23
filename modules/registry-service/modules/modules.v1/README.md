# Terraform Modules API in API Gateway

This Terraform module is a building block that creates API Gateway resources
and methods (under a given pre-existing API) that together implement the
Terraform module registry API in terms of a given DynamoDB table.

```hcl
module "modules_v1" {
  source = "apparentlymart/tf-registry/aws//modules/modules.v1"

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
