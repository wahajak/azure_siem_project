# ================================
# TERRAFORM CONFIGURATION FOR LOGIC APP PLAYBOOK (UPDATED)
# ================================

# Variables
variable "playbook_name" {
  description = "Name of the Logic App playbook"
  type        = string
  default     = "sentinel-incident-response-playbook"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

# Client configuration
data "azurerm_client_config" "current" {}

# Office 365 API Connection
resource "azurerm_api_connection" "office365" {
  name                = "${var.playbook_name}-office365-connection"
  resource_group_name = azurerm_resource_group.rg.name
  managed_api_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/${var.location}/managedApis/office365"
  display_name        = "Office 365 Connection"
  tags = {
    purpose = "sentinel-automation"
  }
}

# Sentinel API Connection
resource "azurerm_api_connection" "sentinel" {
  name                = "${var.playbook_name}-sentinel-connection"
  resource_group_name = azurerm_resource_group.rg.name
  managed_api_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/${var.location}/managedApis/azuresentinel"
  display_name        = "Azure Sentinel Connection"
  tags = {
    purpose = "sentinel-automation"
  }
}

# Logic App Workflow
resource "azurerm_logic_app_workflow" "incident_response" {
  name                = var.playbook_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  workflow_parameters = {
    "$connections" = jsonencode({
      type = "Object"
      defaultValue = {
        office365 = {
          connectionId   = azurerm_api_connection.office365.id
          connectionName = azurerm_api_connection.office365.name
          id             = azurerm_api_connection.office365.managed_api_id
        }
        azuresentinel = {
          connectionId   = azurerm_api_connection.sentinel.id
          connectionName = azurerm_api_connection.sentinel.name
          id             = azurerm_api_connection.sentinel.managed_api_id
        }
      }
    })
  }

  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"

  tags = {
    purpose = "sentinel-automation"
    type    = "incident-response"
  }

  depends_on = [
    azurerm_api_connection.office365,
    azurerm_api_connection.sentinel
  ]
}


# Automation Rule
resource "azurerm_sentinel_automation_rule" "incident_response_automation" {
  name                       = "8f14e45f-ea5e-4df8-bc0e-0bbf621b5eb3"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Automatic Incident Response"
  order                      = 1
  enabled                    = true
  triggers_on                = "Incidents"
  triggers_when              = "Created"

  condition_json = jsonencode({
    property = "IncidentSeverity"
    operator = "Equals"
    values   = ["High", "Critical"]
  })

  action_playbook {
    logic_app_id = azurerm_logic_app_workflow.incident_response.id
    order        = 1
    tenant_id    = data.azurerm_client_config.current.tenant_id
  }

  depends_on = [azurerm_logic_app_workflow.incident_response]
}

# Outputs
output "playbook_id" {
  value = azurerm_logic_app_workflow.incident_response.id
}

output "playbook_name" {
  value = azurerm_logic_app_workflow.incident_response.name
}

output "office365_connection_id" {
  value = azurerm_api_connection.office365.id
}

output "sentinel_connection_id" {
  value = azurerm_api_connection.sentinel.id
}
