output "endpoint" {
  value = digitalocean_container_registry.this.endpoint
}

output "secret_name" {
  value = local.secret_name
}