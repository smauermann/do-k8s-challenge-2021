terraform {
  backend "remote" {
    organization = "this"

    workspaces {
      name = "do-k8s-challenge-2021"
    }
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

provider "digitalocean" {}
