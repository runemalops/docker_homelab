# Production environment outputs

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
    traefik     = "https://${var.domain}"
    portainer   = "https://portainer.${var.domain}"
    prometheus  = "https://prometheus.${var.domain}"
    grafana     = "https://grafana.${var.domain}"
  }
}

output "ansible_inventory" {
  description = "Ansible inventory file content"
  value       = module.docker.ansible_inventory
}

output "backup_status" {
  description = "Backup configuration status"
  value = {
    enabled  = var.backup_enabled
    schedule = var.backup_schedule
  }
}

output "monitoring_config" {
  description = "Monitoring configuration"
  value = {
    retention_days = var.monitoring_retention_days
    enabled        = var.enable_monitoring
  }
}