## Create APIM
resource "azurerm_api_management" "apim" {
    name                = "apim-sync-openapi-defs-demo"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    publisher_name      = "mytechramblings"
    publisher_email     = "me@mytechramblings.com"
    sku_name            = "Developer_1"
}

## Import App A to APIM using directly the OpenApi import feature
resource "azurerm_api_management_api" "apim_app_a_api" {
  name                = "app-a-webapi"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "app-a-webapi"
  path                = "app-a"
  protocols           = ["https"]
  service_url         = "https://${azurerm_container_app.aca_app_a.ingress[0].fqdn}"
  subscription_required = false

  import {
    content_format = "openapi+json-link"
    content_value  = "https://${azurerm_container_app.aca_app_a.ingress[0].fqdn}/swagger/v1/swagger.json"
  }
}

## Import App B to APIM using OpenApi alongside with the Terraform http resource
data "http" "apim_app_b_openapi" {
  url = "https://${azurerm_container_app.aca_app_b.ingress[0].fqdn}/swagger/v1/swagger.json"
  request_headers = {
    Accept = "application/json"
  }
}

## Import App B to APIM using OpenApi alongside with the Terraform http resource
resource "azurerm_api_management_api" "apim_app_b_api" {
  name                = "app-b-webapi"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "app-b-webapi"
  path                = "app-b"
  protocols           = ["https"]
  service_url         = "https://${azurerm_container_app.aca_app_b.ingress[0].fqdn}"
  subscription_required = false

  import {
    content_format = "openapi+json"
    content_value  = data.http.apim_app_b_openapi.response_body
  }
}