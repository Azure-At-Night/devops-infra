locals {
  default_commit_email = "filip.vagner@azureatnight.com"
  primary_location     = "centralus"
  naming_suffix        = ["atn", "devops", "rnrs"]
  tags = {
    scenario = "default"
  }

  resource_groups = {
    rg_001 = {
      name = "${module.naming.resource_group.name}-001"
    }
    rg_002 = {
      name = "${module.naming.resource_group.name}-002"
    }
    rg_003 = {
      name = "${module.naming.resource_group.name}-003"
    }
    rg_004 = {
      name = "${module.naming.resource_group.name}-004"
    }
    rg_005 = {
      name = "${module.naming.resource_group.name}-005"
    }
  }

  identities = {
    id_001 = {
      name                = "${module.naming.user_assigned_identity.name}-001"
      resource_group_name = module.rg["rg_001"].name
      credentials = {
        runners_001 = {
          name     = "atn-devops-runners"
          audience = ["api://AzureADTokenExchange"]
          issuer   = "https://token.actions.githubusercontent.com"
          subject  = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main"
        }
      }
      role_assignments = {
        contributor = {
          scope              = "/subscriptions/${var.azure_subscription_id}"
          role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        }
        storage_data_owner = {
          scope              = "/subscriptions/${var.azure_subscription_id}"
          role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
        }
        storage_blob_data_contributor = {
          scope              = "/subscriptions/${var.azure_subscription_id}"
          role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
        }
        key_vault_administrator = {
          scope              = "/subscriptions/${var.azure_subscription_id}"
          role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
        }
        user_access_administrator = {
          scope              = "/subscriptions/${var.azure_subscription_id}"
          role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
          condition_version  = "2.0"
          condition          = <<-EOT
          (
            (
              !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
            )
            OR 
            (
              @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
            )
          )
          AND
          (
            (
              !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
            )
            OR 
            (
              @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
            )
          )
          EOT
        }
      }
    }
  }

  github_actions_variables = {
    tfbackend_resource_group = {
      repository    = var.github_repository_name
      variable_name = "TFBACKEND_RESOURCE_GROUP"
      value         = var.tfbackend_resource_group
    }
    tfbackend_storage_account = {
      repository    = var.github_repository_name
      variable_name = "TFBACKEND_STORAGE_ACCOUNT"
      value         = var.tfbackend_storage_account
    }
  }

  github_actions_secrets = {
    azure_tenant_id = {
      repository      = var.github_repository_name
      secret_name     = "AZURE_TENANT_ID"
      plaintext_value = var.azure_tenant_id
    }
    azure_subscription_id = {
      repository      = var.github_repository_name
      secret_name     = "AZURE_SUBSCRIPTION_ID"
      plaintext_value = var.azure_subscription_id
    }
    id_001_client_id = {
      repository      = var.github_repository_name
      secret_name     = "ID_001_AZURE_CLIENT_ID"
      plaintext_value = azurerm_user_assigned_identity.id["id_001"].client_id
    }
  }

  runners = {
    # runners1 = {
    #   resource_group_name                          = module.rg["rg_001"].name
    #   postfix                                      = join("-", concat(local.naming_suffix, ["001"]))
    #   version_control_system_organization          = var.github_organization_name
    #   version_control_system_personal_access_token = var.github_runners_personal_access_token
    #   version_control_system_enterprise            = var.github_organization_name
    #   container_instance_count                     = 1
    #   container_instance_container_cpu             = 1
    #   container_instance_container_cpu_limit       = 1
    #   container_instance_container_memory          = 2
    #   container_instance_container_memory_limit    = 2
    #   container_instance_container_name            = module.naming.container_app.name
    #   user_assigned_managed_identity_id            = azurerm_user_assigned_identity.id["id_001"].id
    #   user_assigned_managed_identity_principal_id  = azurerm_user_assigned_identity.id["id_001"].principal_id
    # }
    # runners2 = {
    #   resource_group_name                          = module.rg["rg_002"].name
    #   postfix                                      = join("-", concat(local.naming_suffix, ["002"]))
    #   version_control_system_organization          = var.github_organization_name
    #   version_control_system_personal_access_token = var.github_runners_personal_access_token
    #   version_control_system_pool_name            = "atn-devops-rnrs"
    #   container_instance_count                     = 1
    #   container_instance_container_cpu             = 1
    #   container_instance_container_cpu_limit       = 1
    #   container_instance_container_memory          = 2
    #   container_instance_container_memory_limit    = 2
    #   container_instance_container_name            = module.naming.container_app.name
    #   user_assigned_managed_identity_id            = azurerm_user_assigned_identity.id["id_001"].id
    #   user_assigned_managed_identity_principal_id  = azurerm_user_assigned_identity.id["id_001"].principal_id
    #   use_private_networking                       = true
    #   container_instance_subnet_id                  = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/runners2"
    #   virtual_network_id                            = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs"
    #   nat_gateway_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/natGateways/ng-atn-devops-rnrs"
    #   container_registry_private_endpoint_subnet_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/container-registry-private-endpoint"
    # }
    runners3 = {
      resource_group_name                                  = module.rg["rg_003"].name
      postfix                                              = join("-", concat(local.naming_suffix, ["003"]))
      version_control_system_organization                  = var.github_organization_name
      version_control_system_personal_access_token         = var.github_runners_personal_access_token
      version_control_system_repository                    = var.github_repository_name
      container_instance_count                             = 1
      container_instance_container_cpu                     = 2
      container_instance_container_cpu_limit               = 2
      container_instance_container_memory                  = 4
      container_instance_container_memory_limit            = 4
      container_instance_container_name                    = module.naming.container_app.name
      user_assigned_managed_identity_id                    = azurerm_user_assigned_identity.id["id_001"].id
      user_assigned_managed_identity_principal_id          = azurerm_user_assigned_identity.id["id_001"].principal_id
      use_private_networking                               = true
      virtual_network_id                                   = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs"
      container_instance_subnet_id                         = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/runners3"
      container_registry_private_endpoint_subnet_id        = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/container-registry-private-endpoint"
      container_registry_private_dns_zone_creation_enabled = false
      container_registry_dns_zone_id                       = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
    }
  }

  runners_groups = {
    # To find repository ID, go to repository, in browser open developer tools (F12) and look for value "octolytics-dimension-repository_id"
    runners1 = {
      name        = "atn-devops-rnrs"
      description = "Github runners group for ATN DevOps"
      visibility  = "selected"
      # selected_repository_ids = [
      #   "960415963" # devops-infra
      # ]
    }
  }
}

#region Resource Providers
locals {
  default_resource_providers = [
    "Microsoft.App",
    "Microsoft.Authorization",
    "Microsoft.Automation",
    "Microsoft.Compute",
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.ContainerService",
    "Microsoft.CostManagement",
    "Microsoft.CustomProviders",
    "Microsoft.DataProtection",
    "microsoft.insights",
    "Microsoft.Maintenance",
    "Microsoft.ManagedIdentity",
    "Microsoft.ManagedServices",
    "Microsoft.Management",
    "Microsoft.Network",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.PolicyInsights",
    "Microsoft.RecoveryServices",
    "Microsoft.Resources",
    "Microsoft.Security",
    "Microsoft.SecurityInsights",
    "Microsoft.Storage",
    "Microsoft.StreamAnalytics"
  ]

  resource_providers_by_subscriptions = flatten([
    for resource_provider in local.default_resource_providers :
    {
      subscription_id   = var.azure_subscription_id
      resource_provider = resource_provider
    }
  ])

  resource_providers_to_register = {
    for resource_provider in local.resource_providers_by_subscriptions : "${resource_provider.subscription_id}_${resource_provider.resource_provider}" => resource_provider
  }
}
#endregion Resource Providers
