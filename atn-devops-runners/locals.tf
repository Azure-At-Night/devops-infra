locals {
  default_commit_email = "filip.vagner@azureatnight.com"
  free_plan            = "free"
  primary_location                = "centralus"

  resource_providers_to_register = {
    atn-management = {
      resource_provider = "Microsoft.App"
    }
  }

  tags = {
    scenario = "default"
  }

  excluded_regions = [
  ]
  included_regions = [
    "cenrtalus",
    "eastus",
  ]
  regions         = local.included_regions
  selected_region = "centralus"

  compute_types = [
    "azure_container_instance"
  ]

  approvers = [
    #"filipvagner"
  ]

  environments = {
    "dev" = {
      name = "dev"
      protected = false
    }
    "staging" = {
      name = "staging"
      protected = false
    }
    "prod" = {
      name = "prod"
      protected = true
    }
  }
}
