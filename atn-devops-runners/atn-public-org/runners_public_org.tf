#region Custom module - Public Runners GitHub organization scope
module "custom_runner_public" {
  source = "../runners-module"

  resource_group_name = module.rg["rg_002"].name
  location            = module.primary_location.name

  container_registry_name       = "acrorbrnr002"
  container_registry_sku        = "Basic"
  zone_redundancy_enabled       = false
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
      context_path         = "https://github.com/filipvagner/github-runner-aci#a0fe69a:github-runner-aci"
      context_access_token = "a"
      image_names          = ["github-runner:a0fe69a"]
    }
  }

  container_instance_count                    = 1
  container_instance_name                     = "ci-orb-rnr-002"
  container_instance_use_availability_zones   = true
  user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_002"].id
  user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_002"].principal_id
  use_private_networking                      = false
  environment_variables = {
    GH_RUNNER_URL = "https://github.com/Azure-At-Night"
    GH_RUNNER_LABELS = "atn,public,azure"
    GH_RUNNER_TOKEN_API_URL = "https://api.github.com/orgs/Azure-At-Night/actions/runners/registration-token"
  }
  sensitive_environment_variables = {
    GH_RUNNER_TOKEN = var.github_runners_personal_access_token
  }
  container_instance_workspace_id  = var.workspace_id
  container_instance_workspace_key = var.workspace_key
}
#endregion Custom module - Public Runners GitHub organization scope
