# Create resource group
resource "azurerm_resource_group" "rg" {
    name      = "rg-demo"
    location  = "West Europe"
}