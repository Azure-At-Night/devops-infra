locals {
  locations = {
    primary_location = "centralus"
  }
  naming_suffix                                 = ["atn", "rnrs"]
  container_registry_private_endpoint_subnet_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-atn-rnr-network-sst-cus-001/providers/Microsoft.Network/virtualNetworks/vnet-atn-rnr-network-sst-cus-001/subnets/snet-atn-rnr-network-acr-1"

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
      credentials = {
        # runners_001 = {
        #   name     = "atn-devops-runners"
        #   audience = ["api://AzureADTokenExchange"]
        #   issuer   = "https://token.actions.githubusercontent.com"
        #   subject  = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main"
        # }
      }
      # role_assignments = {
      #   contributor = {
      #     scope              = "/subscriptions/${var.azure_subscription_id}"
      #     role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      #   }
      #   storage_data_owner = {
      #     scope              = "/subscriptions/${var.azure_subscription_id}"
      #     role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
      #   }
      #   storage_blob_data_contributor = {
      #     scope              = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${module.rg["rg_001"].name}"
      #     role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
      #   }
      #   key_vault_administrator = {
      #     scope              = "/subscriptions/${var.azure_subscription_id}/${module.rg["rg_001"].name}"
      #     role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
      #   }
      #   user_access_administrator = {
      #     scope              = "/subscriptions/${var.azure_subscription_id}/${module.rg["rg_001"].name}"
      #     role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      #     condition_version  = "2.0"
      #     condition          = <<-EOT
      #     (
      #       (
      #         !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
      #       )
      #       OR 
      #       (
      #         @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
      #       )
      #     )
      #     AND
      #     (
      #       (
      #         !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
      #       )
      #       OR 
      #       (
      #         @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
      #       )
      #     )
      #     EOT
      #   }
      # }
    }
  }
}

#region Custom module - Internal Runners GitHub organization scope
module "custom_runner_internal" {
  source = "../runners-module"

  resource_group_name = module.rg["rg_003"].name
  location            = module.primary_location.name

  container_registry_name       = "acrorbrnr003"
  container_registry_sku        = "Premium"
  zone_redundancy_enabled       = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
  container_registry_diagnostic_settings = {
    acr-all = {
      workspace_resource_id = local.log_analytics_workspace_id
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
      private_dns_zone_resource_ids = [local.container_registry_dns_zone_id]
      # application_security_group_associations = {
      #   asg1 = local.application_security_group_resource_id
      # }
    }
  }

  container_instance_count                    = 1
  container_instance_name                     = "ci-orb-rnr-003"
  container_instance_use_availability_zones   = true
  user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_003"].id
  user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_003"].principal_id
  use_private_networking                      = false
  environment_variables = {
    GH_RUNNER_URL = "https://github.com/Azure-At-Night"
    GH_RUNNER_LABELS = "atn,internal,azure"
    GH_RUNNER_TOKEN_API_URL = "https://api.github.com/orgs/Azure-At-Night/actions/runners/registration-token"
  }
  sensitive_environment_variables = {
    GH_RUNNER_TOKEN = var.github_runners_personal_access_token
  }
  container_instance_workspace_id  = var.workspace_id
  container_instance_workspace_key = var.workspace_key
}
#endregion Custom module - Internal Runners GitHub organization scope
