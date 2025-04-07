variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID."
}

variable "azure_subscription_id" {
  type        = string
  description = "Subscription ID where is storage account name for TF state."
}

variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}

variable "github_runners_personal_access_token" {
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire)."
  type        = string
  sensitive   = true
}

variable "github_repository_name" {
  description = "Repository name."
  type = string
  sensitive = false
}
