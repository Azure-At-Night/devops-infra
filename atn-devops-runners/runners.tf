#region Custom module - Public Runners
module "custom_runner_public" {
  source = "../runners-module"

  resource_group_name = module.rg["rg_002"].name
  location            = module.primary_location.name

  container_registry_name       = join("", concat(local.naming_suffix, ["rm"], ["002"]))
  container_registry_sku        = "Premium"
  public_network_access_enabled = true
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
      context_path         = "https://github.com/filipvagner/github-runner-aci#63f4d76:github-runner-aci"
      context_access_token = "a"
      image_names          = ["github-runner:63f4d76"]
    }
  }

  container_instance_count                    = 1
  container_instance_container_name           = "atn-rnrs-rm-002"         #join("-", concat(local.naming_suffix, ["rm"], ["001"]))
  container_instance_name_prefix              = "atn-rnrs-rm-002"         #module.naming.container_app.name #join("-", concat(local.naming_suffix, ["rn"], ["001"]))
  container_registry_login_server             = "atnrnrsrm002.azurecr.io" #FIXME this has to be handled within module
  container_image                             = "github-runner:63f4d76"   #FIXME this has to be handled within module
  user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_002"].id
  user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_002"].principal_id
  use_private_networking                      = false
  github_organization_name                    = var.github_organization_name
  github_repository_name                      = var.github_repository_name
  sensitive_environment_variables = {
    GH_RUNNER_TOKEN = var.github_runners_personal_access_token
  }
  container_instance_workspace_id  = "09891203-6418-453c-a543-d1522b0cdac7"
  container_instance_workspace_key = "obxMAEpMUdRwBXOzI5UyBwp/1WrKqshtNqfrbBhV4aECIde4JV7MeKpkcDbAqyb/dUACaf/s2r51Cztl11wmoA=="

  version_control_system_type                  = "github"
  version_control_system_personal_access_token = var.github_runners_personal_access_token
  version_control_system_organization          = var.github_organization_name
  version_control_system_repository            = var.github_repository_name
}
#endregion Custom module - Public Runners

#region Custom module - Internal Runners with custom DNS zone
# module "custom_runner_internal" {
#   source = "../runners-module"

#   resource_group_name = module.rg["rg_003"].name
#   location            = module.primary_location.name

#   container_registry_name       = join("", concat(local.naming_suffix, ["rm"], ["003"]))
#   container_registry_sku        = "Premium"
#   public_network_access_enabled = false
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
#   container_registry_private_endpoints = {
#     pe-acr = {
#       subnet_resource_id            = local.container_registry_private_endpoint_subnet_id
#       private_dns_zone_resource_ids = [local.container_registry_dns_zone_id]
#       # application_security_group_associations = {
#       #   asg1 = local.application_security_group_resource_id
#       # }
#     }
#   }
#   custom_container_registry_images = {
#     avm_img = {
#       task_name            = "github-container-instance-image-build-task"
#       dockerfile_path      = "dockerfile"
#       context_path         = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners#bc4087f:github-runner-aci"
#       context_access_token = "a"
#       image_names          = ["github-runner:bc4087f"]
#     }
#   }

#   container_instance_count                    = 1
#   container_instance_container_name           = "atn-rnrs-rm-003" #join("-", concat(local.naming_suffix, ["rm"], ["001"]))
#   container_instance_name_prefix              = "atn-rnrs-rm-003"
#   container_registry_login_server             = "atnrnrsrm003.azurecr.io" #FIXME this has to be handled within module
#   container_image                             = "github-runner:bc4087f"   #FIXME this has to be handled within module
#   user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_003"].id
#   user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_003"].principal_id
#   use_private_networking                      = true
#   subnet_id                                   = "/subscriptions/638c6283-9805-468e-b517-2e5d8717e23a/resourceGroups/rg-manualresources/providers/Microsoft.Network/virtualNetworks/vnet-atn-devops-rnrs/subnets/runners3"
#   github_organization_name                    = var.github_organization_name
#   github_repository_name                      = var.github_repository_name
#   sensitive_environment_variables = {
#     GH_RUNNER_TOKEN = var.github_runners_personal_access_token
#   }
#   container_instance_workspace_id  = "09891203-6418-453c-a543-d1522b0cdac7"
#   container_instance_workspace_key = "obxMAEpMUdRwBXOzI5UyBwp/1WrKqshtNqfrbBhV4aECIde4JV7MeKpkcDbAqyb/dUACaf/s2r51Cztl11wmoA=="

#   version_control_system_type                  = "github"
#   version_control_system_personal_access_token = var.github_runners_personal_access_token
#   version_control_system_organization          = var.github_organization_name
#   version_control_system_repository            = var.github_repository_name
# }
#endregion Custom module - Internal Runners with custom DNS zone
