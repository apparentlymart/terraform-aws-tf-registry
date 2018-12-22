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
