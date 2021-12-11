terraform {
  backend "remote" {
    organization = "this"

    workspaces {
      name = "do-k8s-challenge-2021"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

provider "digitalocean" {}

provider "kubernetes" {
  host  = module.k8s.cluster_endpoint
  token = module.k8s.cluster_token

  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
}
