resource "aws_dynamodb_table" "modules" {
  name = var.dynamodb_table_name

  hash_key  = "Id"
  range_key = "Version"

  #billing_mode = "PAY_PER_REQUEST"
  read_capacity  = 1
  write_capacity = 1

  # Id is the full namespace/name/provider string used to identify a particular module.
  attribute {
    name = "Id"
    type = "S"
  }

  # Version is a normalized semver-style version number, like 1.0.0.
  attribute {
    name = "Version"
    type = "S"
  }
}
