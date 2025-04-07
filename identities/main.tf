module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

module "primary_location" {
  source  = "azurerm/locations/azure"
  version = "0.2.4"

  location = local.primary_location
}

#region Provider registration
resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}
#endregion Provider registration

#region Resource Group
module "rg" {
  for_each = local.resource_groups

  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = each.value.name
  location = try(each.value.location, local.primary_location)
  tags     = each.value.tags
}
#endregion Resource Group

#region User Assigned Identity, credentials and role assignments
resource "azurerm_user_assigned_identity" "ado_runners" {
  name                = "id-atn-devops-001"
  location            = module.primary_location.name
  resource_group_name = module.rg["rg_mgmt_shared"].name
  tags = merge(
    local.tags,
    {
      Workload    = "Identity for Azure DevOps Runners"
      Criticality = "High"
    }
  )
}

resource "azurerm_federated_identity_credential" "ado_runners" {
  name                = "uoou-ado-runners"
  resource_group_name = module.rg["rg_mgmt_shared"].name
  parent_id           = azurerm_user_assigned_identity.ado_runners.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azuredevops_serviceendpoint_azurerm.ado_runners.workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurerm.ado_runners.workload_identity_federation_subject
}

resource "azurerm_role_assignment" "rbac" {
  scope              = "/providers/Microsoft.Management/managementGroups/${var.root_parent_management_group_id}"
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  principal_id       = azurerm_user_assigned_identity.ado_runners.principal_id
  principal_type     = "ServicePrincipal"
}
#endregion User Assigned Identity, credentials and role assignments

#region Key Vault
# module "kv" {
#   for_each = local.keyvaults

#   source  = "Azure/avm-res-keyvault-vault/azurerm"
#   version = "0.10.0"

#   name                       = each.value.name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   location                   = each.value.location
#   resource_group_name        = each.value.resource_group_name
#   enable_telemetry           = false
#   sku_name                   = each.value.sku_name
#   purge_protection_enabled   = each.value.purge_protection_enabled
#   soft_delete_retention_days = each.value.soft_delete_retention_days
#   tags                       = each.value.tags

#   network_acls     = each.value.network_acls
#   secrets          = each.value.secrets
#   secrets_value    = each.value.secrets_value
#   role_assignments = each.value.role_assignments
# }
#endregion Key Vault
