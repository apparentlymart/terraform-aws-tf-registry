# This is a supporting module used by the "integration.tftest" scenario,
# which tries to create a real API gateway resource and so needs a supporting
# temporary REST API to create it in.

terraform {
  experiments = [smoke_tests]
}

resource "aws_api_gateway_rest_api" "test" {
  name = "terraform-aws-tf-registry-test-${random_pet.test.id}"
}

resource "random_pet" "test" {
}

module "disco" {
  source = "../../"

  rest_api_id = aws_api_gateway_rest_api.test.id
  services    = {}
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.test.id

  depends_on = [module.disco.discovery_doc_resource_id]
}

resource "aws_api_gateway_stage" "test" {
  rest_api_id   = aws_api_gateway_deployment.test.rest_api_id
  deployment_id = aws_api_gateway_deployment.test.id
  stage_name    = "test"
}

# Ideally we'd have this smoke test inside the module itself, but the module
# can't know the base URL of the generated API because that isn't determined
# until it's deployed with aws_api_gateway_deployment, and that is outside
# of the disco module's scope since it expects to be used with a REST API
# object declared elsewhere.
smoke_test "fetch" {
  data "http" "disco" {
    url = "${aws_api_gateway_stage.test.invoke_url}/.well-known/terraform.json"
  }

  postcondition {
    condition     = jsondecode(data.http.disco.response_body) == jsondecode("{}")
    error_message = format(
      "unexpected discovery document content from %s: %#v",
      data.http.disco.url,
      jsondecode(data.http.disco.response_body),
    )
  }
}
