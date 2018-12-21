module "modules_store" {
  source = "./modules/modules-store"

  dynamodb_table_name = local.modules_table_name
}
