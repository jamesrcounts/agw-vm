locals {
  ip_configuration_name = "vm-nic-config"
  vm_name               = "vm-${local.project}"
}

# Create public IP
resource "azurerm_public_ip" "publicip_vm" {
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.example.location
  name                = "pip-${local.vm_name}"
  resource_group_name = data.azurerm_resource_group.example.name
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  location            = data.azurerm_resource_group.example.location
  name                = "nic-${local.vm_name}"
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = local.ip_configuration_name
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip_vm.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
}

// # Add nic to load balancer
// resource "azurerm_network_interface_backend_address_pool_association" "example" {
//   network_interface_id    = azurerm_network_interface.nic.id
//   ip_configuration_name   = local.ip_configuration_name
//   backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
// }

# Add nic to nsg
resource "azurerm_network_interface_security_group_association" "nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  location              = data.azurerm_resource_group.example.location
  name                  = local.vm_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  resource_group_name   = data.azurerm_resource_group.example.name
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    name              = "os-${local.vm_name}"
  }

  storage_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    admin_password = "Password1234!"
    admin_username = "plankton"
    computer_name  = local.vm_name
    custom_data    = file("scripts/install-nginx.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "network_watcher" {
  name                       = "AzureNetworkWatcherExtension"
  virtual_machine_id         = azurerm_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}
