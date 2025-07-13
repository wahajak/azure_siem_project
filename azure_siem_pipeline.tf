provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "sentinel-rg"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "sentinelWorkspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.law.id
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}