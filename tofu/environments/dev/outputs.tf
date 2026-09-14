# Development environment outputs

output "docker_host" {
  description = "Docker host URL"
  value       = var.docker_host
}

output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "network_id" {
  description = "Docker network ID"
  value       = module.network.network_id
}

output "network_name" {
  description = "Docker network name"
  value       = module.network.network_name
}

output "storage_paths" {
  description = "Storage paths created"
  value       = module.storage.storage_paths
}

output "service_endpoints" {
  description = "Service endpoints"
  value = {
    traefik     = "http://${var.domain}:8080"
    portainer   = "http://${var.domain}:9000"
    prometheus  = "http://${var.domain}:9090"
    grafana     = "http://${var.domain}:3000"
  }
}

output "ansible_inventory" {
  description = "Ansible inventory file content"
  value       = module.docker.ansible_inventory
}