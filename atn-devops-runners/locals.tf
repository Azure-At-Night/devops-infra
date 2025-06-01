locals {
  default_commit_email                          = "filip.vagner@azureatnight.com"
  primary_location                              = "centralus"
  naming_suffix                                 = ["atn", "rnrs"]
  log_analytics_workspace_id                    = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourcegroups/rg-manualresources/providers/microsoft.operationalinsights/workspaces/log-atn-devops-rnrs"
  container_registry_private_endpoint_subnet_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-atn-rnr-network-sst-cus-001/providers/Microsoft.Network/virtualNetworks/vnet-atn-rnr-network-sst-cus-001/subnets/snet-atn-rnr-network-acr-1"
  container_registry_dns_zone_id                = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
  application_security_group_resource_id        = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/resourceGroups/rg-manualresources/providers/Microsoft.Network/applicationSecurityGroups/asg-fiva-rnrs"

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
    # id_001 = {
    #   name                = "${module.naming.user_assigned_identity.name}-001"
    #   resource_group_name = module.rg["rg_001"].name
    #   credentials = {
    #     runners_001 = {
    #       name     = "atn-devops-runners"
    #       audience = ["api://AzureADTokenExchange"]
    #       issuer   = "https://token.actions.githubusercontent.com"
    #       subject  = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main"
    #     }
    #   }
    #   role_assignments = {
    #     contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    #     }
    #     storage_data_owner = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    #     }
    #     storage_blob_data_contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    #     }
    #     key_vault_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
    #     }
    #     user_access_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    #       condition_version  = "2.0"
    #       condition          = <<-EOT
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
    #         )
    #         OR 
    #         (
    #           @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       AND
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
    #         )
    #         OR 
    #         (
    #           @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       EOT
    #     }
    #   }
    # }
    # id_002 = {
    #   name                = "${module.naming.user_assigned_identity.name}-002"
    #   resource_group_name = module.rg["rg_002"].name
    #   credentials = {
    #     runners_001 = {
    #       name     = "atn-devops-runners"
    #       audience = ["api://AzureADTokenExchange"]
    #       issuer   = "https://token.actions.githubusercontent.com"
    #       subject  = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main"
    #     }
    #   }
    #   role_assignments = {
    #     contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    #     }
    #     storage_data_owner = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    #     }
    #     storage_blob_data_contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    #     }
    #     key_vault_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
    #     }
    #     user_access_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    #       condition_version  = "2.0"
    #       condition          = <<-EOT
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
    #         )
    #         OR 
    #         (
    #           @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       AND
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
    #         )
    #         OR 
    #         (
    #           @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       EOT
    #     }
    #   }
    # }
    # id_003 = {
    #   name                = "${module.naming.user_assigned_identity.name}-003"
    #   resource_group_name = module.rg["rg_003"].name
    #   credentials = {
    #     runners_001 = {
    #       name     = "atn-devops-runners"
    #       audience = ["api://AzureADTokenExchange"]
    #       issuer   = "https://token.actions.githubusercontent.com"
    #       subject  = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main"
    #     }
    #   }
    #   role_assignments = {
    #     contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    #     }
    #     storage_data_owner = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    #     }
    #     storage_blob_data_contributor = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    #     }
    #     key_vault_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
    #     }
    #     user_access_administrator = {
    #       scope              = "/subscriptions/${var.azure_subscription_id}"
    #       role_definition_id = "/subscriptions/${var.azure_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    #       condition_version  = "2.0"
    #       condition          = <<-EOT
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
    #         )
    #         OR 
    #         (
    #           @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       AND
    #       (
    #         (
    #           !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
    #         )
    #         OR 
    #         (
    #           @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, b24988ac-6180-42a0-ab88-20f7382dd24c, 76cc9ee4-d5d3-4a45-a930-26add3d73475, 92b92042-07d9-4307-87f7-36a593fc5850, a8889054-8d42-49c9-bc1c-52486c10e7cd, f58310d9-a9f6-439a-9e8d-f62e7b41a168, 32e6a4ec-6095-4e37-b54b-12aa350ba81f, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9}
    #         )
    #       )
    #       EOT
    #     }
    #   }
    # }
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
