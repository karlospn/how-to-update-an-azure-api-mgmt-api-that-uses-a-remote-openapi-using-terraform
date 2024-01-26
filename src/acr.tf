# Create acr
resource "azurerm_container_registry" "acr" {
    name                    = "crdemotf01"
    resource_group_name     = azurerm_resource_group.rg.name
    location                = azurerm_resource_group.rg.location
    sku                     = "Standard"
}