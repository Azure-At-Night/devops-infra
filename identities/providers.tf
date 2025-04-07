provider "azurerm" {
  subscription_id     = var.management_subscription_id
  storage_use_azuread = true

  features {
  }
}

provider "azuredevops" {
  personal_access_token = var.azure_devops_personal_access_token
  org_service_url       = var.azure_devops_organization_url
}
