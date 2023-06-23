# Modules Index in DynamoDB

This Terraform module is a building block that creates a DynamoDB table ready
to store items describing Terraform modules available for installation.

```hcl
module "modules_store" {
  source = "apparentlymart/tf-registry/aws//modules/modules-store"

  dynamodb_table_name = "any-name-you-like"
  bucket_name = "any-name-you-like"
}
```

You can control dynamodb capacity with `dynamodb_store_capacity` parameter.