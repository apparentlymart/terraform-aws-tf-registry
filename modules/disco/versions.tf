terraform {
  required_version = ">= 0.12.0"

  # HACK: the current "terraform test" prototype doesn't understand how to
  # discover "dev dependencies" through the test scenarios, so we need to
  # declare these providers here so that they'll be available for the test
  # scenarios. A final "terraform test" should automatically notice that
  # the scenarios have additional dependencies and install them whenever
  # initializing the module directory itself, but not when the module is
  # being called from elsewhere.
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
