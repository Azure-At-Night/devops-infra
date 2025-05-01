#region Naming
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"

  suffix = local.naming_suffix
}
#endregion Naming

#region Lcocation
module "primary_location" {
  source  = "azurerm/locations/azure"
  version = "0.2.4"

  location = local.primary_location
}
#endregion Lcocation

#region Resource Providers registration
resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${var.azure_subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}
#endregion Resource Providers registration

#region Resource Group
module "rg" {
  for_each = local.resource_groups

  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = each.value.name
  location = try(each.value.location, module.primary_location.name)
}
#region Resource Group

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

#region Github Action variables and secrets
resource "github_actions_variable" "gha_variable" {
  for_each = local.github_actions_variables

  repository    = each.value.repository
  variable_name = each.value.variable_name
  value         = each.value.value
}

resource "github_actions_secret" "gha_secret" {
  for_each = local.github_actions_secrets

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = try(each.value.plaintext_value, null)
  encrypted_value = try(each.value.encrypted_value, null)
}
#endregion Github Action variables and secrets

#region Github runnners groups
resource "github_actions_runner_group" "gha_runner_group" {
  for_each = local.runners_groups

  name                       = each.value.name
  restricted_to_workflows    = try(each.value.restricted_to_workflows, false)
  selected_repository_ids    = try(each.value.selected_repository_ids, null)
  selected_workflows         = try(each.value.selected_workflows, null)
  visibility                 = each.value.visibility
  allows_public_repositories = try(each.value.allows_public_repositories, false)
}
#endregion Github runnners groups

#region Runners
module "github_runners" {
  for_each = local.runners

  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "0.3.2"

  enable_telemetry                                = var.enable_telemetry
  location                                        = try(each.value.location, module.primary_location.name)
  resource_group_name                             = each.value.resource_group_name
  resource_group_creation_enabled                 = false
  postfix                                         = each.value.postfix
  version_control_system_type                     = "github"
  version_control_system_organization             = each.value.version_control_system_organization
  version_control_system_personal_access_token    = each.value.version_control_system_personal_access_token
  version_control_system_repository               = try(each.value.version_control_system_repository, null)
  version_control_system_enterprise               = try(each.value.version_control_system_enterprise, null)
  version_control_system_pool_name                = try(each.value.version_control_system_pool_name, null)
  compute_types                                   = ["azure_container_instance"]
  container_instance_count                        = each.value.container_instance_count
  container_instance_container_cpu                = each.value.container_instance_container_cpu
  container_instance_container_cpu_limit          = each.value.container_instance_container_cpu_limit
  container_instance_container_memory             = each.value.container_instance_container_memory
  container_instance_container_memory_limit       = each.value.container_instance_container_memory_limit
  container_instance_container_name               = each.value.container_instance_container_name
  log_analytics_workspace_creation_enabled        = false
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = each.value.user_assigned_managed_identity_id
  user_assigned_managed_identity_principal_id     = each.value.user_assigned_managed_identity_principal_id
  use_private_networking                          = try(each.value.use_private_networking, false)
  virtual_network_creation_enabled                = false
  virtual_network_id                              = try(each.value.virtual_network_id, null)
  container_instance_subnet_id                    = try(each.value.container_instance_subnet_id, null)
  container_registry_private_endpoint_subnet_id   = try(each.value.container_registry_private_endpoint_subnet_id, null)
  nat_gateway_creation_enabled                    = false
  nat_gateway_id                                  = try(each.value.nat_gateway_id, null)
}
#endregion Runners

#region Custom module - Public Runners
# module "custom_runner" {
#   source = "../runners-module"

#   resource_group_name           = module.rg["rg_002"].name
#   location                      = module.primary_location.name
#   container_registry_name       = join("", concat(local.naming_suffix, ["rn"], ["001"]))
#   container_registry_sku        = "Premium"
#   public_network_access_enabled = true
#   network_rule_bypass_option    = "AzureServices"
#   # container_registry_lock = {
#   #   name = "acrrnrsmodule1"
#   #   kind = "CanNotDelete"
#   # }
#   container_registry_diagnostic_settings = {
#     acr-all = {
#       workspace_resource_id = local.log_analytics_workspace_id
#     }
#   }
#   # container_registry_private_endpoints = {
#   #   pe-acr = {
#   #     subnet_resource_id = local.container_registry_private_endpoint_subnet_id
#   #     private_dns_zone_resource_ids = [local.container_registry_dns_zone_id]
#   #     application_security_group_associations = {
#   #       asg1 = local.application_security_group_resource_id
#   #     }
#   #   }
#   # }
#   custom_container_registry_images = {
#     avm_img = {
#       task_name            = "github-container-instance-image-build-task"
#       dockerfile_path      = "dockerfile"
#       context_path         = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners#bc4087f:github-runner-aci"
#       context_access_token = "a"
#       image_names          = ["github-runner:bc4087f"]
#     }
#   }

#   container_instance_name           = join("-", concat(local.naming_suffix, ["rn"], ["001"]))
#   container_name                    = join("-", concat(local.naming_suffix, ["rn"], ["001"]))
#   container_registry_login_server   = "atnrnrsrn001.azurecr.io"
#   container_image                   = "github-runner:bc4087f"
#   user_assigned_managed_identity_id = azurerm_user_assigned_identity.id["id_002"].id
#   user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_002"].principal_id
#   use_private_networking = false
# }
#endregion Custom module - Public Runners

#region Custom module - Internal Runners with custom DNS zone
#endregion Custom module - Internal Runners with custom DNS zone
