# Docker module - Manages Docker resources

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

variable "docker_host" {
  description = "Docker host URL"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# Resources

# Create Docker networks
resource "docker_network" "monitoring" {
  name   = "monitoring_network"
  driver = "bridge"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_network" "web" {
  name   = "web_network"
  driver = "bridge"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_network" "databases" {
  name   = "databases_network"
  driver = "bridge"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_network" "networking" {
  name   = "networking_network"
  driver = "bridge"
  labels {
    label = "environment"
    value = var.environment
  }
}

# Create Docker volumes
resource "docker_volume" "prometheus_data" {
  name = "prometheus_data"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_volume" "grafana_data" {
  name = "grafana_data"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
  labels {
    label = "environment"
    value = var.environment
  }
}

resource "docker_volume" "redis_data" {
  name = "redis_data"
  labels {
    label = "environment"
    value = var.environment
  }
}

# Outputs
output "monitoring_network_id" {
  description = "Monitoring network ID"
  value       = docker_network.monitoring.id
}

output "web_network_id" {
  description = "Web network ID"
  value       = docker_network.web.id
}

output "databases_network_id" {
  description = "Databases network ID"
  value       = docker_network.databases.id
}

output "networking_network_id" {
  description = "Networking network ID"
  value       = docker_network.networking.id
}

output "ansible_inventory" {
  description = "Ansible inventory content"
  value       = <<-EOT
    all:
      hosts:
        localhost:
          ansible_connection: local
          docker_network: homelab_network
          docker_compose_path: /home/runemal/Documents/docker_homelab
          environment: ${var.environment}
          domain: ${var.domain}
  EOT
}