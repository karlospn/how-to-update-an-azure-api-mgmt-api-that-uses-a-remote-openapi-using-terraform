resource "azurerm_api_management_product" "demo" {
  product_id            = "Demo"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
  display_name          = "Demo APIs"
  subscription_required = false
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product_api" "demo_product_app_a_assignment" {
  api_name            = azurerm_api_management_api.apim_app_a_api.name
  product_id          = azurerm_api_management_product.demo.product_id
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_api_management_product_api" "demo_product_app_b_assignment" {
  api_name            = azurerm_api_management_api.apim_app_b_api.name
  product_id          = azurerm_api_management_product.demo.product_id
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
}
