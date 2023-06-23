# Changelog


## v1.0.2

- documentation fix for registry.terraform.io

## v1.0.1

- documentation update
- integration to https://registry.terraform.io/modules/geronimo-iia/tf-registry/aws/latest

## v1.0.0 (current not released)

Features:

- add JWT Secret initialization
- add lambda autorizer
- automate API gateway redeployment
- add dedicated bucket storage
- add python script to deploy terraform module
- add control of dynamodb capacity (provisioned, pay per request, ...)
- add tags on resource
- add dynamodb capacity management and custom naming
- add bucket custom naming
- add storage output

Docs:

- add architecture overview
- add example
- add more information in readme

Refacto:

- group all modules.v1 api inside the dedicated module
- registry-store module resource is external of registry-service
- keep default value of variable at root module level

Fix:

- remove usage ot template provider: https://registry.terraform.io/providers/hashicorp/template/latest/docs#deprecation
- fix error in default settings

