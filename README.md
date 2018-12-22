# Terraform Private Registry for AWS

This Terraform module establishes a private registry for Terraform, allowing
you to publish your own modules in a location you control independent of
Terraform's public registry at [`registry.terraform.io`](https://registry.terraform.io/).

Terraform module addresses can include
an optional hostname part which allows them to be downloaded from services
other than the public registry:

```hcl
module "awesomeapp" {
  source = "tf.example.com/awesomecorp/awesomeapp/aws"
}
```

The module in _this_ repository provides the API endpoints necessary to provide
such a module source hostname.
Terraform's documented registry HTTP API is implemented via Amazon API Gateway
relaying requests to a DynamoDB table that contains a simple index of modules.
The module packages themselves can be stored at any non-registry
[module source address](https://www.terraform.io/docs/modules/sources.html)
supported by Terraform, including in an S3 bucket with standard AWS
authentication.

This module requires Terraform 0.12 or newer.

If using this module in production, be sure to select a specific version via
a version constraint argument in your `module` block to avoid surprising
changes during upgrades. This module uses semantic versioning, and so new
minor releases may introduce additional features that may lead to additional
cost.

For the moment this module remains EXPERIMENTAL. Once we've heard good feedback
about how it behaves in real-world situations it will be blessed with a
non-experimental version number (1.0 or greater).

## Simple Usage

When called with no arguments, this module will create a registry API with
no access control backed by a DynamoDB table called `TerraformRegistry-modules`:

```hcl
module "tf_registry" {
  source = "apparentlymart/tf-registry/aws"
}

output "rest_api_id" {
  value = module.tf_registry.rest_api_id
}

output "services" {
  value = module.tf_registry.services
}
```

Since the registry is just an index for module packages stored elsewhere, it
may be acceptable in some environments to allow unauthenticated access to the
registry API while protecting access to the packages themselves, and so the
above may be sufficient to get started.

After the initial creation of the registry, the DynamoDB table will be empty.
Use any normal strategy for population of the registry, such as the DynamoDB
management console, the AWS CLI, or a custom program using an AWS SDK.
For the sake of example here, we'll create an alias for the HashiCorp Consul
module in the public registry using the AWS CLI:

```
aws dynamodb put-item \
  --table-name TerraformRegistry-modules \
  --item '{
      "Id": {"S":"hashicorp/consul/aws"},
      "Version": {"S":"0.4.4"},
      "Source": {"S":"https://api.github.com/repos/hashicorp/terraform-aws-consul/tarball/v0.4.4//*?archive=tar.gz"}
  }'
```

The `{"S":...}` objects here are the DynamoDB convention for indicating a string
value. The `Id` and `Version` attributes together form the primary key for the
table, and `Source` specifies a
[module source address](https://www.terraform.io/docs/modules/sources.html)
where the module package can be downloaded. In this case, we indicate a `.tar.gz`
archive of a tag from a repository on GitHub.

The `terraform apply` log should include a value for the `services` output
indicated in the configuration above, which will look something like this:

```
Outputs:

rest_api_id = b9h60hion6
services = {
  "modules.v1" = "https://b9h60hion6.execute-api.us-west-2.amazonaws.com/live/modules.v1/"
}
```

This map value is a service discovery document for
[Terraform's service discovery protocol](https://www.terraform.io/docs/internals/remote-service-discovery.html). For
normal use it would be necessary to publish a JSON version of this document
at `/.well-known/terraform.json` on an HTTPS server running at the hostname
that will be used to install modules, but for initial testing we can use an
override configuration in
[the Terraform CLI config file](https://www.terraform.io/docs/commands/cli-config.html) (_not_ your
infrastructure configuration in `.tf` files):

```hcl
host "tf.example.com" {
  services = {
    "modules.v1" = "https://b9h60hion6.execute-api.us-west-2.amazonaws.com/live/modules.v1/"
  }
}
```

With this block in place, Terraform will use this hard-coded map instead of
trying to request a discovery document over the network. From another separate
Terraform configuration we should then be able to request the Consul module
via this private registry:

```hcl
module "consul" {
  source = "tf.example.com/hashicorp/consul/aws"

  # ...
}
```

The module installer in `terraform init` should then be able to download the
module by first requesting its package location from our private registry.

The remaining sections of this README will cover some other options and
configuration details.

## Customizing AWS Object Names

By default, this module creates various objects across a number of different
AWS services using names starting with `TerraformRegistry`. You can customize
this prefix by setting the `name_prefix` argument:

```hcl
module "tf_registry" {
  source = "apparentlymart/tf-registry/aws"

  name_prefix = "AnotherTerraformRegistry"
}
```

Changing this name after the module is initially created requires re-creating
all remote objects, including the underlying DynamoDB table. That means any
data in that table would be lost and must be restored from backup.

## Re-deploying the API after Changes

Most customizations in the following sections cause changes to the API Gateway
configuration. Due to the design of API Gateway, such changes must be explicitly
re-deployed after Terraform has finished applying them.

To do this, look for the `rest_api_id` output value in the `terraform apply`
output and insert as the `--rest-api-id` value in the following AWS CLI command
line:

```
aws apigateway create-deployment \
    --rest-api-id b9h60hion6 \
    --stage-name live
```

This will be necessary after any `terraform apply` whose plan includes changes
to resources with types starting with `aws_api_gateway_`.

## Publishing the Discovery Document

If you already have an HTTPS server running on a suitable hostname then
you can make your private registry accessible via that hostname by publishing
a JSON version of the discovery map at `/.well-known/terraform.json` on that
server:

```json
{
  "modules.v1": "https://b9h60hion6.execute-api.us-west-2.amazonaws.com/live/modules.v1/"
}
```

For example, to make the above example hostname `tf.example.com` work without
local overrides, the discovery document would need to be published at
`https://tf.example.com/.well-known/terraform.json`.

### Automatic Discovery Document

If you'd rather keep the whole registry deployment self-contained, this
`tf-registry` module can optionally publish itself at a hostname of your choice
and host its own JSON discovery document like the above.

For this to work you will first need to create and verify an
[AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
certificate in the same region where this module is being deployed.
Such a certificate can be
[provisioned automatically in Terraform](https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html#dns-validation-with-route-53)
if your domain is hosted in Route53.

With the certificate created, the optional `friendly_hostname` argument for
this module calls for the hostname mapping to be configured:

```hcl
module "tf_registry" {
  source = "apparentlymart/tf-registry/aws"

  friendly_hostname = {
    host                = aws_acm_certificate.cert.domain_name
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  }
}
```

When `friendly_hostname` is set, the module will additionally configure API
Gateway to serve the registry API and an automatically-generated discovery
document at the given hostname and with the given certificate.

To complete this configuration, you'll need to create an entry in your DNS
zone to point requests at the registry API. If you're using Route53 then you
can create an alias record using `aws_route53_record`:

```hcl
resource "aws_route53_record" "tf" {
  zone_id = var.your_zone_id

  name = aws_acm_certificate.cert.domain_name
  type = "A"
  alias {
    name    = module.tf_registry.dns_alias.hostname
    zone_id = module.tf_registry.dns_alias.route53_zone_id
  }
}
```

After giving time for the changes to propagate, you should be able to request
the discovery document at your hostname using `curl`, such as the following
example continuing to use `tf.example.com`:

```
$ curl https://tf.example.com/.well-known/terraform.json
{
  "modules.v1":"/modules.v1/"
}
```

Once this works, Terraform should be able to find modules via that hostname.
If you added a `host` block to the Terraform CLI configuration during the
"Simple Usage" steps above, remember to remove it to allow Terraform to do
normal discovery over the network.

## Access Control

Terraform CLI supports bearer-token authentication credentials when making
API requests. Credentials are configured on a per-hostname basis and apply
to all services at that hostname. An authentication token for a particular
hostname can be configured using
[a `credentials` block in the CLI configuration](https://www.terraform.io/docs/commands/cli-config.html#credentials).

This module has no built-in support for authentication, but you can add
token authentication by writing
[an AWS Lambda-based authorizer function](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html)
that checks submitted API tokens in any way that makes sense for your environment.

Once you have written an authorizer function, you can enable it for your
registry using the optional `lambda_authorizer` argument:

```hcl
module "tf_registry" {
  source = "apparentlymart/tf-registry/aws"

  lambda_authorizer = {
    type          = "TOKEN"
    function_name = aws_lambda_function.auth.function_name
  }
}
```

The `type` attribute can be set to either `TOKEN` or `REQUEST`, depending on
which calling convention the authorizer function is expecting. If `TOKEN`
is selected, the function recieves the content of the `Authorization` HTTP
header, where Terraform CLI places any configured bearer token.

When writing your authorizer function, remember that the `Authorization` header
value has a `Bearer` prefix to indicate that Terraform is using bearer token
authentication. Your function must check for this and then strip it off before
checking whether the rest of the header value is a valid token.

The details of writing an authorizer function are beyond the scope of this
readme. For more information, see
[Introducing custom authorizers in Amazon API Gateway](https://aws.amazon.com/blogs/compute/introducing-custom-authorizers-in-amazon-api-gateway/) from the AWS Compute Blog.

## Advanced Scenarios Using the Submodules

The top-level module in this package is intended as a good set of defaults for
a simple registry deployment. If you need more control in your environment,
you may prefer to use directly the sub-modules that the top-level module
is constructed from, which can be composed together in different ways to
make different tradeoffs:

- [`modules-store`](./modules/modules-store/) manages the DynamoDB table that
  stores the module registry index.
- [`modules.v1`](./modules/modules.v1/) implements the version 1 HTTP API
  that Terraform CLI expects, using API Gateway against a given DynamoDB
  table which is assumed to be one created by the `modules-store` module.
- [`disco`](./modules/disco/) adds a `/.well-known/terraform.json` discovery
  document to the root of any given API Gateway REST API.

None of these sub-modules create an API Gateway REST API themselves, so you
can write your own module that creates and configures a REST API as meets your
needs and then use these sub-modules to populate it with the modules API
functionality and, if desired, a discovery document.
