output "discovery_doc_resource_id" {
  value = aws_api_gateway_resource.well_known_terraform.id

  depends_on = [
    # The resource isn't ready to use until all of its downstream configuration
    # objects are ready. The integration response depends on everything else
    # upstream, and so is sufficient to cover everything else indirectly.
    aws_api_gateway_integration_response.well_known_terraform_GET_200
  ]
}
