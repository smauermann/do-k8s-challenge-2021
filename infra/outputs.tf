output "kubernetes_version" {
  value = module.k8s.k8s_version
}

output "registry_endpoint" {
  value = module.registry.endpoint
}

output "registry_secret_name" {
  value = module.registry.secret_name
}