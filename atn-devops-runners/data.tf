data "azurerm_client_config" "current" {}

data "github_repository" "this" {
  full_name = join("/", ["Azure-At-Night", "devops-infra"])
}
