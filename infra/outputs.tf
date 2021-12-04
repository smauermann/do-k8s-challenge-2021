output "kubernetes_version" {
  value = data.digitalocean_kubernetes_versions.this.latest_version
}
