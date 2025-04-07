module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

module "primary_location" {
  source  = "azurerm/locations/azure"
  version = "0.2.4"

  location = local.primary_location
}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}

module "rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = "rg-atn-devops-runners-001"
  location = module.primary_location.name
}

resource "azurerm_user_assigned_identity" "id" {
  name                = "id-atn-devops-runners-001"
  location            = module.primary_location.name
  resource_group_name = module.rg.name
}

resource "azurerm_federated_identity_credential" "id_fed_cred" {
  name                = "atn-devops-runners"
  resource_group_name = module.rg.name
  parent_id           = azurerm_user_assigned_identity.id.principal_id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:Azure-At-Night/devops-infra:ref:refs/heads/main" # "repo:Azure-At-Night/bootstrap-runners:environment:aprove"
}

resource "azurerm_role_assignment" "contributor" {
  scope              = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a"
  role_definition_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  principal_id       = azurerm_user_assigned_identity.id.principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "storage_data_owner" {
  scope              = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a"
  role_definition_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
  principal_id       = azurerm_user_assigned_identity.id.principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "key_vault_administrator" {
  scope              = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a"
  role_definition_id = "/subscriptions/018805fe-880b-417d-bf6b-6eccfbefac5a/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483"
  principal_id       = azurerm_user_assigned_identity.id.principal_id
  principal_type     = "ServicePrincipal"
}

#region Github variables
resource "github_actions_variable" "azure_tenant_id" {
  repository    = var.github_repository_name
  variable_name = "AZURE_TENANT_ID"
  value         = var.azure_tenant_id
}

resource "github_actions_variable" "azure_subscription_id" {
  repository    = var.github_repository_name
  variable_name = "AZURE_SUBSCRIPTION_ID"
  value         = var.azure_subscription_id
}

resource "github_actions_variable" "azure_client_id" {
  repository    = var.github_repository_name
  variable_name = "AZURE_CLIENT_ID"
  value         = azurerm_user_assigned_identity.id.id
}
#endregion Github variables

#region Runners
# module "github_runners" {
#   source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
#   version = "0.3.2"

#   postfix                                      = "atn-devops-runners"
#   location                                     = local.selected_region
#   version_control_system_organization          = var.github_organization_name
#   version_control_system_personal_access_token = var.github_runners_personal_access_token
#   version_control_system_type                  = "github"
#   version_control_system_repository            = github_repository.bootstrap_runners.name
#   compute_types                                = local.compute_types
#   container_instance_container_cpu             = 2
#   container_instance_container_cpu_limit       = 2
#   container_instance_container_memory          = 4
#   container_instance_container_memory_limit    = 4
#   container_instance_container_name            = "${module.naming.container_app.name}-atn-runners"
#   container_instance_count                     = 2
#   use_private_networking                       = false
#   tags                                         = local.tags
#   #depends_on                                   = [github_repository_file.this]
# }
#endregion Runners
