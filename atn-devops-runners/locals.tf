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

  github_actions_variables = {}

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
    runners1 = {
      resource_group_name                          = module.rg["rg_001"].name
      postfix                                      = join("-", concat(local.naming_suffix, ["001"]))
      version_control_system_organization          = var.github_organization_name
      version_control_system_personal_access_token = var.github_runners_personal_access_token
      version_control_system_repository            = var.github_repository_name
      container_instance_count                     = 2
      container_instance_container_cpu             = 1
      container_instance_container_cpu_limit       = 1
      container_instance_container_memory          = 2
      container_instance_container_memory_limit    = 2
      container_instance_container_name            = module.naming.container_app.name
      user_assigned_managed_identity_id            = azurerm_user_assigned_identity.id["id_001"].id
      user_assigned_managed_identity_principal_id  = azurerm_user_assigned_identity.id["id_001"].principal_id
    }
    runners2 = {
      resource_group_name                          = module.rg["rg_002"].name
      postfix                                      = join("-", concat(local.naming_suffix, ["002"]))
      version_control_system_organization          = var.github_organization_name
      version_control_system_personal_access_token = var.github_runners_personal_access_token
      version_control_system_repository            = var.github_repository_name
      container_instance_count                     = 2
      container_instance_container_cpu             = 1
      container_instance_container_cpu_limit       = 1
      container_instance_container_memory          = 2
      container_instance_container_memory_limit    = 2
      container_instance_container_name            = module.naming.container_app.name
      user_assigned_managed_identity_id            = azurerm_user_assigned_identity.id["id_001"].id
      user_assigned_managed_identity_principal_id  = azurerm_user_assigned_identity.id["id_001"].principal_id
    }
  }

  runners_groups = {
    runners1 = {
      name        = "atn-devops-rnrs-001"
      description = "Github runners group for atn-devops-rnrs-001"
      visibility  = "all"
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
