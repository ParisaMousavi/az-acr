resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  retention_policy {
    days    = 7
    enabled = true
  }
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_set {
    default_action = "Deny"
    dynamic "ip_rule" {
      for_each = var.network_rule_set.allow_ip_ranges
      content {
        action   = "Allow"
        ip_range = ip_rule.value
      }
    }
    dynamic "virtual_network" {
      for_each = var.network_rule_set.allow_subnet_ids
      content {
        action    = "Allow"
        subnet_id = virtual_network.value
      }
    }
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

# Deployment Private Endpoint
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
resource "azurerm_private_endpoint" "this" {
  count = var.network_config.subnet_id == null ? 0 : 1
  depends_on = [
    azurerm_private_dns_zone.this
  ]
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_config.subnet_id

  private_service_connection {
    name                           = "${var.name}-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.this[0].name
    private_dns_zone_ids = [azurerm_private_dns_zone.this[0].id]
  }

  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

resource "azurerm_private_dns_zone" "this" {
  count               = var.network_config.subnet_id == null ? 0 : 1
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = var.network_config.virtual_network_id == null ? 0 : 1
  name                  = "${var.name}-vnet2dns"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[0].name
  virtual_network_id    = var.network_config.virtual_network_id
}
