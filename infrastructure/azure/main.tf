locals {
  instance_id = data.azurerm_resource_group.example.tags["instance_id"]
  tags        = data.azurerm_resource_group.example.tags
}
