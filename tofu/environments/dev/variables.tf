# Development environment variables

variable "docker_host" {
  description = "Docker host URL"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "domain" {
  description = "Domain name for the homelab"
  type        = string
  default     = "localhost"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
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
  default     = false
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