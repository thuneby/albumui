locals {
  fqdn = "https://${data.azurerm_container_app.api.ingress[0].fqdn}"
}

resource "azurecaf_name" "app_name" {
  name          = "albumui"
  resource_type = "azurerm_container_app"
  clean_input   = true
}

resource "azurerm_user_assigned_identity" "albumui" {
  location            = data.azurerm_resource_group.applications.location
  name                = "id-albumui"
  resource_group_name = data.azurerm_resource_group.applications.name
}

resource "azurerm_container_app" "application" {
  name                         = azurecaf_name.app_name.result
  container_app_environment_id = data.azurerm_container_app_environment.applications.id
  resource_group_name          = data.azurerm_resource_group.applications.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      liveness_probe {
        port      = 3000
        transport = "HTTP"
      }
      env {
        name  = "API_BASE_URL"
        value = local.fqdn
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.albumui.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.albumui.id
  }

  lifecycle {
    ignore_changes = [
      tags, template
    ]
  }

  depends_on = [
    azurecaf_name.app_name, azurerm_user_assigned_identity.albumui
  ]

}

resource "azurerm_role_assignment" "container_registry_acrpull_user_assigned" {
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
  principal_id         = azurerm_user_assigned_identity.albumui.principal_id

  depends_on = [
    azurerm_container_app.application
  ]
}