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
  count               = var.private_endpoint_config.subnet_id == null ? 0 : 1
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_config.subnet_id
  private_service_connection {
    name                           = "${var.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
  }
  private_dns_zone_group {
    name                 = "${var.name}-psc-group" # Private Service Connection Name
    private_dns_zone_ids = [var.private_endpoint_config.private_dns_zone_id]
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = var.private_endpoint_config.private_dns_zone_name != null && var.private_endpoint_config.virtual_network_id != null ? 1 : 0
  name                  = "${var.name}-vnet2dns"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_endpoint_config.private_dns_zone_name
  virtual_network_id    = var.private_endpoint_config.virtual_network_id
}

