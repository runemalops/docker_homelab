# Production environment configuration

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  
  backend "s3" {
    bucket         = "homelab-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "docker" {
  host = var.docker_host
}

# Local variables for DRY principle
locals {
  environment = "prod"
  domain      = var.domain
  common_tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
    Project     = "homelab"
    Critical    = "true"
  }
}

# Import base configuration
module "docker" {
  source = "../../modules/docker"
  
  environment = local.environment
  domain      = local.domain
  docker_host = var.docker_host
  common_tags = local.common_tags
}

module "network" {
  source = "../../modules/network"
  
  environment     = local.environment
  network_name    = "homelab_network"
  network_driver  = "bridge"
  network_subnet  = "172.20.0.0/16"
  network_gateway = "172.20.0.1"
  common_tags     = local.common_tags
}

module "storage" {
  source = "../../modules/storage"
  
  environment  = local.environment
  base_path    = "/var/lib/homelab"
  common_tags  = local.common_tags
}