# Storage module - Manages storage directories and volumes

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "base_path" {
  description = "Base path for storage"
  type        = string
  default     = "/var/lib/homelab"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# Local variables
locals {
  directories = [
    "${var.base_path}",
    "${var.base_path}/config",
    "${var.base_path}/data",
    "${var.base_path}/logs",
    "${var.base_path}/backups",
    "${var.base_path}/monitoring",
    "${var.base_path}/databases",
    "${var.base_path}/media",
    "${var.base_path}/downloads",
  ]
}

# Create directories
resource "null_resource" "storage_dirs" {
  for_each = toset(local.directories)
  
  provisioner "local-exec" {
    command = "mkdir -p ${each.value}"
  }
}

# Create a summary file
resource "local_file" "storage_summary" {
  content = <<-EOT
    Homelab Storage Configuration
    Environment: ${var.environment}
    Base Path: ${var.base_path}
    
    Directories created:
    ${join("\n    ", [for dir in local.directories : "- ${dir}"])}
    
    Created by Terraform at: ${timestamp()}
  EOT
  filename = "${var.base_path}/storage_summary.txt"
}

# Outputs
output "storage_paths" {
  description = "Storage paths created"
  value       = local.directories
}

output "base_path" {
  description = "Base storage path"
  value       = var.base_path
}

output "summary_file" {
  description = "Summary file path"
  value       = local_file.storage_summary.filename
}