terraform {
  required_version = ">= 1.9"

  backend "local" {}

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
