locals {
  root_parent_management_group_id = var.root_parent_management_group_id
  organization_url                = var.azure_devops_organization_url
  default_commit_email            = "filip.vagner@orbit.cz"
  primary_location                = "centralus"

  resource_groups = {
    rg_mgmt_shared = {
      name = "${module.naming.resource_group.name}-uoou-mgmt-shared-001"
      tags = {
        workload    = "Shared resources"
        Criticality = "Medium"
      }
    }
  }
}

#region Runners
locals {
  runners_compute_types = [
    "azure_container_instance"
  ]
}
#endregion Runners

#region Resource Providers
locals {
  default_resource_providers = [
    "Microsoft.Authorization",
    "Microsoft.Automation",
    "Microsoft.Compute",
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.ContainerService",
    "Microsoft.CostManagement",
    "Microsoft.CustomProviders",
    "Microsoft.DataProtection",
    "microsoft.insights",
    "Microsoft.Maintenance",
    "Microsoft.ManagedIdentity",
    "Microsoft.ManagedServices",
    "Microsoft.Management",
    "Microsoft.Network",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.PolicyInsights",
    "Microsoft.RecoveryServices",
    "Microsoft.Resources",
    "Microsoft.Security",
    "Microsoft.SecurityInsights",
    "Microsoft.Storage",
    "Microsoft.StreamAnalytics"
  ]

  resource_providers_by_subscriptions = flatten([
    for resource_provider in local.default_resource_providers :
    {
      subscription_id   = data.azurerm_subscription.current.subscription_id
      resource_provider = resource_provider
    }
  ])

  resource_providers_to_register = {
    for resource_provider in local.resource_providers_by_subscriptions : "${resource_provider.subscription_id}_${resource_provider.resource_provider}" => resource_provider
  }
}
#endregion Resource Providers
