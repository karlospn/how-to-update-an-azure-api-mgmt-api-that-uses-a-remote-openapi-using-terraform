## Create an User Assigned Identity with ACRPull permissions to attach it to the container apps
resource "azurerm_user_assigned_identity" "aca_apps_user_assigned_identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "id-aca-acrpush"
}

# Add ACRPull permission to user assigned identity
resource "azurerm_role_assignment" "user_assigned_identity_acrpull_role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_apps_user_assigned_identity.principal_id
}
