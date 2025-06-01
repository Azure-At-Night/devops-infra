#region Custom module - Public Runners
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
      context_path         = "https://github.com/filipvagner/github-runner-aci#63f4d76:github-runner-aci"
      context_access_token = "a"
      image_names          = ["github-runner:63f4d76"]
    }
  }

  container_instance_count                    = 2
  container_instance_name                     = "ci-orb-rnr-002"
  container_instance_use_availability_zones = true
  user_assigned_managed_identity_id           = azurerm_user_assigned_identity.id["id_002"].id
  user_assigned_managed_identity_principal_id = azurerm_user_assigned_identity.id["id_002"].principal_id
  use_private_networking                      = false
  environment_variables = {
    GH_RUNNER_URL  = "https://github.com/${var.github_organization_name}/${var.github_repository_name}/"
  }
  sensitive_environment_variables = {
    GH_RUNNER_TOKEN = var.github_runners_personal_access_token
  }
  container_instance_workspace_id  = var.workspace_id
  container_instance_workspace_key = var.workspace_key
}
#endregion Custom module - Public Runners
