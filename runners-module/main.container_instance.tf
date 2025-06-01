variable "container_image" {
  type        = string
  description = "Image of the container"
  default     = null
  nullable    = true
}

variable "container_registry_login_server" {
  type        = string
  description = "Login server of the container registry"
  default     = null
}

variable "user_assigned_managed_identity_id" {
  type        = string
  description = "ID of the user-assigned managed identity"
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "List of availability zones"
}

variable "container_cpu" {
  type        = number
  default     = 2
  description = "CPU value for the container"
}

variable "container_cpu_limit" {
  type        = number
  default     = 2
  description = "CPU limit for the container"
}

variable "container_memory" {
  type        = number
  default     = 4
  description = "Memory value for the container"
}

variable "container_memory_limit" {
  type        = number
  default     = 4
  description = "Memory limit for the container"
}

variable "container_registry_password" {
  type        = string
  default     = null
  description = "Password of the container registry"
  sensitive   = true
}

variable "container_registry_username" {
  type        = string
  default     = null
  description = "Username of the container registry"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the container"
}

variable "sensitive_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Secure environment variables for the container"
  sensitive   = true
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "ID of the subnet"
}

variable "use_private_networking" {
  type        = bool
  default     = true
  description = "Flag to indicate whether to use private networking"
}

variable "container_instance_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of additional environment variables to pass to the container."
}

variable "container_instance_sensitive_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  sensitive   = true
  default     = []
  description = "List of additional sensitive environment variables to pass to the container."
}

variable "container_instance_workspace_id" {
  type        = string
  default     = null
  description = "The Workspace ID of the Log Analytics Workspace."
}

variable "container_instance_workspace_key" {
  type        = string
  default     = null
  description = "The Log Analytics Workspace key to access."
}

variable "container_instance_count" {
  type        = number
  description = "The number of container instances to create"
  default     = 1
}

variable "container_instance_name" {
  type        = string
  default     = null
  description = "This is name of container running within container instance resource in Azure."
}

variable "container_instance_use_availability_zones" {
  type        = bool
  default     = false
  description = "Should the container instance be deployed in availability zones."
}

locals {
  container_registry_login_server = var.container_registry_login_server != null ? var.container_registry_login_server : "${var.container_registry_name}.azurecr.io"
  container_image                 = var.container_image != null ? var.container_image : values(var.custom_container_registry_images)[0].image_names[0]
  container_instances = {
    for instance in range(0, var.container_instance_count) : instance => {
      name               = "${var.container_instance_name}-${instance + 1}"
      availability_zones = [(instance % 3) + 1]
    }
  }
}

module "container_instance" {
  source   = "./modules/container-instance"
  for_each = local.container_instances

  location                = var.location
  resource_group_name     = var.resource_group_name
  container_instance_name = each.value.name
  container_name          = var.container_instance_name
  container_image         = local.container_image
  environment_variables = merge(
    var.environment_variables,
    {
      "GH_RUNNER_NAME" = each.value.name
    }
  )
  sensitive_environment_variables   = var.sensitive_environment_variables
  use_private_networking            = var.use_private_networking
  subnet_id                         = try(var.subnet_id, null)
  availability_zones                = var.container_instance_use_availability_zones ? each.value.availability_zones : null
  user_assigned_managed_identity_id = var.user_assigned_managed_identity_id
  container_registry_login_server   = local.container_registry_login_server
  container_instance_workspace_id   = var.container_instance_workspace_id
  container_instance_workspace_key  = var.container_instance_workspace_key

  depends_on = [module.container_registry, time_sleep.delay_after_container_image_build]
}
