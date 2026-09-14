#!/bin/bash
# Homelab backup script
# Backs up Docker volumes and configurations

set -e

# Configuration
BACKUP_DIR="/var/backups/homelab"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup Docker volumes
backup_volumes() {
    log "Backing up Docker volumes..."
    
    VOLUMES=(
        "prometheus_data"
        "grafana_data"
        "portainer_data"
        "postgres_data"
        "redis_data"
    )
    
    for volume in "${VOLUMES[@]}"; do
        if docker volume inspect "$volume" > /dev/null 2>&1; then
            log "Backing up volume: $volume"
            docker run --rm \
                -v "$volume":/source:ro \
                -v "$BACKUP_DIR":/backup \
                alpine tar czf "/backup/${volume}_${DATE}.tar.gz" -C /source .
        else
            warn "Volume $volume does not exist, skipping..."
        fi
    done
}

# Backup configurations
backup_configs() {
    log "Backing up configurations..."
    
    CONFIG_DIRS=(
        "/home/runemal/Documents/docker_homelab/configs"
        "/home/runemal/Documents/docker_homelab/ansible"
        "/home/runemal/Documents/docker_homelab/tofu"
    )
    
    for config_dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$config_dir" ]; then
            log "Backing up: $config_dir"
            tar czf "$BACKUP_DIR/configs_$(basename $config_dir)_${DATE}.tar.gz" \
                -C "$(dirname $config_dir)" "$(basename $config_dir)"
        fi
    done
}

# Backup Docker Compose files
backup_compose() {
    log "Backing up Docker Compose files..."
    
    COMPOSE_DIR="/home/runemal/Documents/docker_homelab"
    tar czf "$BACKUP_DIR/docker_compose_${DATE}.tar.gz" \
        -C "$COMPOSE_DIR" \
        docker-compose.yml \
        .env \
        services/ \
        2>/dev/null || warn "Some compose files may not exist"
}

# Cleanup old backups
cleanup() {
    log "Cleaning up backups older than $RETENTION_DAYS days..."
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
}

# Main execution
main() {
    log "Starting homelab backup..."
    
    backup_volumes
    backup_configs
    backup_compose
    cleanup
    
    log "Backup completed successfully!"
    log "Backup location: $BACKUP_DIR"
}

# Run main function
main "$@"