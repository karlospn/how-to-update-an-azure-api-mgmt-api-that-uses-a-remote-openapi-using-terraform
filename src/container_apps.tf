## Create Azure Container Apps Environment
resource "azurerm_container_app_environment" "aca_env" {
  name                       = "cae-demo"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
}

## Create container app for app A
resource "azurerm_container_app" "aca_app_a" {
    name                         = "ca-app-a"
    container_app_environment_id = azurerm_container_app_environment.aca_env.id
    resource_group_name          = azurerm_resource_group.rg.name
    revision_mode                = "Single"

    template {
        container {
            name   = "app-a-webapi"
            image  = "${azurerm_container_registry.acr.login_server}/app-a-webapi"
            cpu    = 0.5
            memory = "1Gi"
            
            startup_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 240
                interval_seconds        = 30
                failure_count_threshold = 10    
            }

            readiness_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 60
                interval_seconds        = 10
                failure_count_threshold = 3
            }

            liveness_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 60
                initial_delay           = 30   
                interval_seconds        = 10
                failure_count_threshold = 3
            }
        }

        max_replicas =  1
        min_replicas =  1   
    }

    registry {
        server = azurerm_container_registry.acr.login_server
        identity = azurerm_user_assigned_identity.aca_apps_user_assigned_identity.id
    }

    ingress {
        allow_insecure_connections = false
        external_enabled = true
        target_port = 8080
        transport = "http"
        
        traffic_weight {
          latest_revision = true
          percentage = 100
        }
    }

    identity {
      type = "UserAssigned"
      identity_ids = [ azurerm_user_assigned_identity.aca_apps_user_assigned_identity.id ]
    }

    depends_on = [ 
        azurerm_role_assignment.user_assigned_identity_acrpull_role_assignment,
        null_resource.container_image_app_a
    ]
}


## Create container app for app B
resource "azurerm_container_app" "aca_app_b" {
    name                         = "ca-app-b"
    container_app_environment_id = azurerm_container_app_environment.aca_env.id
    resource_group_name          = azurerm_resource_group.rg.name
    revision_mode                = "Single"

    template {
        container {
            name   = "app-b"
            image  = "${azurerm_container_registry.acr.login_server}/app-b-webapi"
            cpu    = 0.5
            memory = "1Gi"
            
            startup_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 240
                interval_seconds        = 30
                failure_count_threshold = 10    
            }

            readiness_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 60
                interval_seconds        = 10
                failure_count_threshold = 3
            }

            liveness_probe {
                port                    = 8080
                transport               = "HTTP"
                path                    = "/health"
                timeout                 = 60
                initial_delay           = 30   
                interval_seconds        = 10
                failure_count_threshold = 3
            }
        }

        max_replicas =  1
        min_replicas =  1   
    }

    registry {
        server = azurerm_container_registry.acr.login_server
        identity = azurerm_user_assigned_identity.aca_apps_user_assigned_identity.id
    }

    ingress {
        allow_insecure_connections = false
        external_enabled = true
        target_port = 8080
        transport = "http"
        
        traffic_weight {
          latest_revision = true
          percentage = 100
        }
    }

    identity {
      type = "UserAssigned"
      identity_ids = [ azurerm_user_assigned_identity.aca_apps_user_assigned_identity.id ]
    }

    depends_on = [ 
        azurerm_role_assignment.user_assigned_identity_acrpull_role_assignment,
        null_resource.container_image_app_b
    ]
}

