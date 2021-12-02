locals {
  application_gateway_name       = "agw-${local.instance_id}"
  backend_address_pool_name      = "${local.application_gateway_name}-beap"
  frontend_port_name             = "${local.application_gateway_name}-feport"
  frontend_ip_configuration_name = "${local.application_gateway_name}-feip"
  http_setting_name              = "${local.application_gateway_name}-be-htst"
  listener_name                  = "${local.application_gateway_name}-httplstn"
  request_routing_rule_name      = "${local.application_gateway_name}-rqrt"
  redirect_configuration_name    = "${local.application_gateway_name}-rdrcfg"
}

resource "azurerm_public_ip" "publicip_agw" {
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.example.location
  name                = "pip-${local.application_gateway_name}"
  resource_group_name = data.azurerm_resource_group.example.name
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_application_gateway" "agw" {
  name                = local.application_gateway_name
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  tags                = local.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicip_agw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = [
      azurerm_public_ip.publicip_vm.ip_address
    ]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
  }
}