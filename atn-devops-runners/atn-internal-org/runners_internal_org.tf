locals {
  locations = {
    primary_location = "centralus"
  }
  naming_suffix                                 = ["atn", "rnrs", "int"]
  container_registry_private_endpoint_subnet_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-atn-rnr-network-sst-cus-001/providers/Microsoft.Network/virtualNetworks/vnet-atn-rnr-network-sst-cus-001/subnets/snet-atn-rnr-network-acr-1"
  container_registry_dns_zone_id                = ["/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"]
  container_instance_subnet_id                  = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/runners1"

  resource_groups = {
    rg_001 = {
      name = "${module.naming.resource_group.name}-001"
    }
  }

  log_analytics = {
    log_001 = {
      name                       = "${module.naming.log_analytics_workspace.name}-001"
      resource_group_name        = module.rg["rg_001"].name
      location                   = module.primary_location.name
      retention_in_days          = 30
      internet_ingestion_enabled = true
      internet_query_enabled     = true
    }
  }

  identities = {
    id_001 = {
      name                = "${module.naming.user_assigned_identity.name}-001"
      resource_group_name = module.rg["rg_001"].name
    }
  }
}

#region Custom module - Internal Runners GitHub organization scope
module "custom_runner_internal" {
  source = "github.com/filipvagner/github-runner-module"

  resource_group_name = module.rg["rg_001"].name
  location            = module.primary_location.name

  container_registry_name       = "${module.naming.container_registry.name}001"
  container_registry_sku        = "Premium"
  zone_redundancy_enabled       = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
  container_registry_diagnostic_settings = {
    acr-all = {
      workspace_resource_id = module.log["log_001"].resource_id
    }
  }
  custom_container_registry_images = {
    avm_img = {
      task_name            = "github-container-instance-image-build-task"
      dockerfile_path      = "dockerfile"
      context_path         = "https://github.com/filipvagner/github-runner-aci#a0fe69a:github-runner-aci"
      context_access_token = "a"
      image_names          = ["github-runner:a0fe69a"]
    }
  }
  container_registry_private_endpoints = {
    pe-acr = {
      subnet_resource_id            = local.container_registry_private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.container_registry_dns_zone_id
      # application_security_group_associations = {
      #   asg1 = local.application_security_group_resource_id
      # }
    }
  }

  container_instance_count                    = 1
  container_instance_name                     = "${module.naming.container_group.name}-001"
  container_instance_use_availability_zones   = true
  user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_001"].id
  user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_001"].principal_id
  use_private_networking                      = true
  subnet_id                                   = local.container_instance_subnet_id
  environment_variables = {
    GH_RUNNER_URL           = "https://github.com/Azure-At-Night"
    GH_RUNNER_LABELS        = "atn,internal,azure"
    GH_RUNNER_TOKEN_API_URL = "https://api.github.com/orgs/Azure-At-Night/actions/runners/registration-token"
  }
  sensitive_environment_variables = {
    GH_RUNNER_TOKEN = var.github_runners_personal_access_token
  }
  container_instance_workspace_id  = module.log["log_001"].resource.workspace_id
  container_instance_workspace_key = module.log["log_001"].resource.primary_shared_key
}
#endregion Custom module - Internal Runners GitHub organization scope
