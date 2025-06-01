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
  container_instance_workspace_id  = var.workspace_id
  container_instance_workspace_key = var.workspace_key

  version_control_system_type                  = "github"
  version_control_system_personal_access_token = var.github_runners_personal_access_token
  version_control_system_organization          = var.github_organization_name
  version_control_system_repository            = var.github_repository_name
}
#endregion Custom module - Public Runners
