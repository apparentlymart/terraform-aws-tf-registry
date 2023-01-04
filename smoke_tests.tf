terraform {
  experiments = [smoke_tests]
}

# FIXME: This smoke test only really makes sense if the registry is set up
# to permit unauthenticated requests. If any credentials are required then
# this will fail with an authentication/authorization error.
#
# This suggests that we will need some way to enable or disable particular
# smoke tests depending on whether the features they are testing are relevant
# for how the module is configured.
smoke_test "disco" {
  data "http" "disco" {
    url = "${local.service_base_url}/.terraform/well-known.json"
  }

  postcondition {
    condition = data.http.disco.response_headers["Content-Type"] == "application/json"
    error_message = format(
      "Discovery document at %s has wrong content type %q.",
      data.http.disco.url,
      data.http.disco.response_headers["Content-Type"],
    )
  }

  postcondition {
    condition = jsondecode(data.http.disco.response_body) == {
      "modules.v1" : "${aws_api_gateway_resource.modules_root.path}/",
    }
    error_message = format(
      "Discovery document at %s has wrong content: %#v",
      data.http.disco.url,
      jsondecode(data.http.disco.response_body),
    )
  }
}
