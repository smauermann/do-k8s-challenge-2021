resource "digitalocean_project" "this" {
  name        = var.project
  description = "Digitalocean Kubernetes Challenge 2021"
  purpose     = "Deploy a scalable message queue"
  environment = "Development"

  resources = [digitalocean_kubernetes_cluster.this.urn]
}

resource "digitalocean_vpc" "this" {
  name   = "${var.project}-vpc"
  region = var.region

  ip_range = var.vpc_range
}

data "digitalocean_kubernetes_versions" "this" {}

resource "digitalocean_kubernetes_cluster" "this" {
  name   = "${var.project}-cluster"
  region = var.region

  version  = data.digitalocean_kubernetes_versions.this.latest_version
  vpc_uuid = digitalocean_vpc.this.id

  auto_upgrade  = true
  surge_upgrade = true

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  node_pool {
    name = "${var.project}-pool"
    size = var.node_pool.size

    auto_scale = var.node_pool.auto_scale
    node_count = var.node_pool.node_count
  }
}
