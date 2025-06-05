#region Naming
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"

  suffix = local.naming_suffix
}
#endregion Naming

#region Location
module "primary_location" {
  source  = "azurerm/locations/azure"
  version = "0.2.4"

  location = local.locations["primary_location"]
}
#endregion Lcocation

#region Resource Group
module "rg" {
  for_each = local.resource_groups

  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = each.value.name
  location = try(each.value.location, module.primary_location.name)
}
#endregion Resource Group

#region Log Analytcis Workspace
module "log" {
  for_each = local.log_analytics

  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  name                                               = each.value.name
  location                                           = try(each.value.location, module.primary_location.name)
  resource_group_name                                = each.value.resource_group_name
  enable_telemetry                                   = false
  log_analytics_workspace_internet_ingestion_enabled = try(each.value.internet_ingestion_enabled, true)
  log_analytics_workspace_internet_query_enabled     = try(each.value.internet_query_enabled, true)
}
#endregion Log Analytics Workspace

#region Identities and RBAC
resource "azurerm_user_assigned_identity" "id" {
  for_each = local.identities

  name                = each.value.name
  location            = try(each.value.location, module.primary_location.name)
  resource_group_name = each.value.resource_group_name
}

locals {
  identitity_creds = {
    for flattened_identity_creds in flatten([
      for k_id, v_id in local.identities : [
        for k_cred, v_cred in lookup(v_id, "credentials", {}) : {
          key                 = "${k_id}-${k_cred}"
          parent_id           = azurerm_user_assigned_identity.id[k_id].id
          resource_group_name = v_id.resource_group_name
          name                = v_cred.name
          audience            = v_cred.audience
          issuer              = v_cred.issuer
          subject             = v_cred.subject
        }
      ]
    ]) : flattened_identity_creds.key => flattened_identity_creds
  }
}

resource "azurerm_federated_identity_credential" "id_fed_cred" {
  for_each = local.identitity_creds

  parent_id           = each.value.parent_id
  resource_group_name = each.value.resource_group_name
  name                = each.value.name
  audience            = each.value.audience
  issuer              = each.value.issuer
  subject             = each.value.subject
}

locals {
  identitity_rbac = {
    for flattened_identity_rbac in flatten([
      for k_id, v_id in local.identities : [
        for k_rbac, v_rbac in lookup(v_id, "role_assignments", {}) : {
          key                  = "${k_id}-${k_rbac}"
          scope                = v_rbac.scope
          role_definition_name = try(v_rbac.role_definition_name, null)
          role_definition_id   = try(v_rbac.role_definition_id, null)
          principal_id         = try(v_rbac.principal_id, azurerm_user_assigned_identity.id[k_id].principal_id)
          principal_type       = try(v_rbac.principal_type, "ServicePrincipal")
          condition            = try(v_rbac.condition, null)
          condition_version    = try(v_rbac.condition_version, null)
          description          = try(v_rbac.description, null)
        }
      ]
    ]) : flattened_identity_rbac.key => flattened_identity_rbac
  }
}

resource "azurerm_role_assignment" "rbac" {
  for_each = local.identitity_rbac

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type
  condition            = try(each.value.condition, null)
  condition_version    = try(each.value.condition_version, null)
  description          = try(each.value.description, null)
}
#endregion Identities and RBAC
