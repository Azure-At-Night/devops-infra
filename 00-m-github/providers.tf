# provider "azurerm" {
#   subscription_id = var.azure_subscription_id
#   features {
#   }
# }

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
}
