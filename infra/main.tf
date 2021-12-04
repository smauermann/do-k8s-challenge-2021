locals {
  project   = "do-k8s-challenge-2021"
  region    = "fra1"
  vpc_range = "10.0.0.0/24"
  node_pool = {
    size      = "s-2vcpu-2gb-amd"
    min_nodes = 1
    max_nodes = 3
  }
}

resource "digitalocean_project" "this" {
  name        = local.project
  description = "Digitalocean Kubernetes Challenge 2021"
  purpose     = "Deploy a scalable message queue"
  environment = "Development"

  resources = [digitalocean_kubernetes_cluster.this.urn]
}

resource "digitalocean_vpc" "this" {
  name   = "${local.project}-vpc"
  region = local.region

  ip_range = local.vpc_range
}

data "digitalocean_kubernetes_versions" "this" {}

resource "digitalocean_kubernetes_cluster" "this" {
  name   = "${local.project}-cluster"
  region = local.region

  version  = data.digitalocean_kubernetes_versions.this.latest_version
  vpc_uuid = digitalocean_vpc.this.id

  node_pool {
    name       = "${local.project}-pool"
    size       = local.node_pool.size
    auto_scale = true
    min_nodes  = local.node_pool.min_nodes
    max_nodes  = local.node_pool.max_nodes
  }
}
