# Network module - Manages Docker networks

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

variable "network_name" {
  description = "Network name"
  type        = string
}

variable "network_driver" {
  description = "Network driver"
  type        = string
  default     = "bridge"
}

variable "network_subnet" {
  description = "Network subnet"
  type        = string
  default     = "172.20.0.0/16"
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
  default     = "172.20.0.1"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# Resources
resource "docker_network" "main" {
  name   = var.network_name
  driver = var.network_driver
  
  ipam_config {
    subnet = var.network_subnet
    gateway = var.network_gateway
  }
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terraform"
  }
}

# Outputs
output "network_id" {
  description = "Network ID"
  value       = docker_network.main.id
}

output "network_name" {
  description = "Network name"
  value       = docker_network.main.name
}

output "network_driver" {
  description = "Network driver"
  value       = docker_network.main.driver
}