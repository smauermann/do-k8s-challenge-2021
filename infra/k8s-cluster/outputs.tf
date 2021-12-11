output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.this.endpoint
}

output "cluster_token" {
  value = digitalocean_kubernetes_cluster.this.kube_config[0].token
}

output "cluster_ca_certificate" {
  value = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
}

output "k8s_version" {
  value = data.digitalocean_kubernetes_versions.this.latest_version
}
