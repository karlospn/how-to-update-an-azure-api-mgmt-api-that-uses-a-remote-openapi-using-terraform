# How to update an Azure API Management API that is configured with a remote OpenApi definition using Terraform

This repository provides an example of how to update an Azure API Management API configured with a remote OpenAPI definition using Terraform.


# **Diagram**

This repository a set of Terraform files that creates the following components.

- An Azure Container Registry to host the application's images.
- An Azure Container Apps Environment to host the applications.
- Two Azure Container Apps running a simple .NET 8 API. Both apps expose the OpenAPI document through the ``/swagger/v1/swagger.json`` endpoint.
- An Azure API Management.
- Two Azure API Management APIs. Both API Management APIs are configured to retrieve its content from the Container Apps swagger endpoint.


![diagram](https://raw.githubusercontent.com/karlospn/how-to-update-an-azure-api-mgmt-api-that-uses-a-remote-openapi-using-terraform/main/docs/scenario-diagram.png)


# How we can update an Azure API Manamgent API that is using a remote OpenApi definition using Terraform?

The next Terraform code snippet shows the simplest way to create an Azure API Mgmt Api configured with a remote OpenAPI definition. 

```yml
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
```

As you can see the ``import`` block is configured to retrieve content from the remote ``/swagger/v1/swagger.json`` endpoint.

However, this scenario poses a problem.    
If someone makes a change to the remote API that modifies the swagger content, such as exposing a new method or altering an existing method, running the ``terraform plan`` command will reveal that Terraform is unable to detect changes in the remote API.    
Consequently, it won't update the API definition in the Azure API Management to reflect the modifications.

![tf-plan](https://raw.githubusercontent.com/karlospn/how-to-update-an-azure-api-mgmt-api-that-uses-a-remote-openapi-using-terraform/main/docs/tf-plan-output.png)

To force the update on the Azure API Management API we have 2 options available.

## **1. Using the revision property**

The ``revision`` property is used to make non-breaking API changes to your API, so you can test changes safely. The usual process involves deploying a new ``revision``, conducting tests, and eventually transitioning from the old to the new revision.

However, we can repurpose this property to instigate the destruction and recreation of the current API. While the original intent of the ``revision`` property is to maintain multiple revisions simultaneously, updating the ``revision`` property of the current API triggers the recreation of the current resource, serving our purpose in this context.   
When the new API is created, it will fetch the updated content from the ``/swagger/v1/swagger.json`` endpoint.

In the following code snippet, the ``revision`` property has been modified from ``1`` to ``2``, triggering the destruction of the existing Azure Api Mgmgt APi and the creation of a new one with the updated revision property.    
Once the new Azure API Management API is created, it will retrieve the latest content from the "https://${azurerm_container_app.aca_app_a.ingress[0].fqdn}/swagger/v1/swagger.json" endpoint.


```yml
resource "azurerm_api_management_api" "apim_app_a_api" {
  name                = "app-a-webapi"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "2"
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
```

## **2. Using the Terraform Http Data Resource**

The Terraform ``http`` data resource makes an HTTP GET request to a given URL and exports information about the response.

In the next code snippet, we utilize the Terraform data ``http`` resource to retrieve the content from the remote Swagger endpoint. Subsequently, we use the output to configure the Azure API Management API.

```yml
data "http" "apim_app_b_openapi" {
  url = "https://${azurerm_container_app.aca_app_b.ingress[0].fqdn}/swagger/v1/swagger.json"
  request_headers = {
    Accept = "application/json"
  }
}

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
```

- **However, what's the advantage of this scenario over the previous one?**

The primary advantage of utilizing the Terraform ``http`` resource is that there is no need to manually modify anything in our Terraform files when someone makes changes to the remote API that modifies the Swagger content.

In the first scenario, we had to manually change the ``revision`` property to trigger the recreation of the API Management API resource.

By employing the Terraform data ``http`` resource, no modifications are required in our Terraform files. The ``http`` resource **ALWAYS** fetchs the content from the remote Swagger endpoint whenever a ``terraform plan`` command is executed.

The following image illustrates this concept.    
We've introduced a modification to the downstream API, and when the ``terraform plan`` command is executed, Terraform seamlessly detects the change and updates the API Management API, thanks to the data ``http`` resource.

![data-http-resource-tf-plan-output](https://raw.githubusercontent.com/karlospn/how-to-update-an-azure-api-mgmt-api-that-uses-a-remote-openapi-using-terraform/main/docs/http-resource-tf-plan-output.png)

- **Which scenario is better?**

To keep always the most up-to-date version of your APIs exposed in your API Management, use the ``http`` resource, it is a better choice, as it eliminates the need to modify anything in your Terraform files.   
When someone makes a change in an API that is exposed in the Azure Api Management, simply run the ``terraform apply`` command and you'll get the latest changes exposed on your Azure Api Management.

While the ``revision`` property can be utilized in this context, it is more apt for a different scenario: maintaining multiple revisions of the same API simultaneously and facilitating non-breaking changes to the current API.    
Keep in mind that if we opt to have multiple revisions of our API at the same time, creating a new revision after the content of the remote Swagger has been updated won't include those changes.