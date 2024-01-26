locals {
  app_a_image_name = "app-a-webapi"
  app_a_image_tag = "latest"
  app_b_image_name = "app-b-webapi"
  app_b_image_tag = "latest"
}

# Create container image for app A and push it to ACR
resource "null_resource" "container_image_app_a" {
    triggers = {
        image_name = local.app_a_image_name
        image_tag = local.app_a_image_tag
        registry_name = azurerm_container_registry.acr.name
        dockerfile_path = "${path.cwd}/AppA.WebApi/Dockerfile"
        dockerfile_context = "${path.cwd}/AppA.WebApi"
        dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "AppA.WebApi/*") : filesha1(f)]))
    }
    provisioner "local-exec" {
        command = "./scripts/docker_build_and_push_to_acr.sh ${self.triggers.image_name} ${self.triggers.image_tag} ${self.triggers.registry_name} ${self.triggers.dockerfile_path} ${self.triggers.dockerfile_context}" 
        interpreter = ["bash", "-c"]
    }
}

# Create container image for app B and push it to ACR
resource "null_resource" "container_image_app_b" {
    triggers = {
        image_name = local.app_b_image_name
        image_tag = local.app_b_image_tag
        registry_name = azurerm_container_registry.acr.name
        dockerfile_path = "${path.cwd}/AppB.WebApi/Dockerfile"
        dockerfile_context = "${path.cwd}/AppB.WebApi"
        dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "AppB.WebApi/*") : filesha1(f)]))
    }
    provisioner "local-exec" {
        command = "./scripts/docker_build_and_push_to_acr.sh ${self.triggers.image_name} ${self.triggers.image_tag} ${self.triggers.registry_name} ${self.triggers.dockerfile_path} ${self.triggers.dockerfile_context}" 
        interpreter = ["bash", "-c"]
    }
}