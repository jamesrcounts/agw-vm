# Read details about the resource group created for this project.
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}