locals {
  secret_name = var.secret_name == "" ? digitalocean_container_registry.this.id : var.secret_name
}

resource "digitalocean_container_registry" "this" {
  name                   = "${var.project}-registry"
  subscription_tier_slug = "basic"
}

resource "digitalocean_container_registry_docker_credentials" "this" {
  registry_name = digitalocean_container_registry.this.id
}

resource "kubernetes_secret_v1" "this" {
  for_each = toset(var.namespaces)

  metadata {
    name      = local.secret_name
    namespace = each.value
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.this.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}