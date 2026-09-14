# Production environment variables

variable "docker_host" {
  description = "Docker host URL"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "domain" {
  description = "Domain name for the homelab"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_databases" {
  description = "Enable database services"
  type        = bool
  default     = true
}

variable "enable_networking" {
  description = "Enable networking services"
  type        = bool
  default     = true
}

variable "enable_web" {
  description = "Enable web services"
  type        = bool
  default     = true
}

variable "enable_media" {
  description = "Enable media services"
  type        = bool
  default     = false
}

variable "enable_utilities" {
  description = "Enable utility services"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Enable backups"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Backup schedule (cron format)"
  type        = string
  default     = "0 2 * * *"
}

variable "monitoring_retention_days" {
  description = "Monitoring data retention in days"
  type        = number
  default     = 90
}