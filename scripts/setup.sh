#!/bin/bash
# Homelab setup script
# Sets up .env file in $HOME/.homelab/

set -e

# Configuration
HOME_DIR="$HOME"
HOMELAB_ENV_DIR="$HOME_DIR/.homelab"
HOMELAB_ENV_FILE="$HOMELAB_ENV_DIR/.env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
ENV_EXAMPLE="$BASE_DIR/.env.example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Create .homelab directory in $HOME
create_home_directory() {
    log "Creating .homelab directory in $HOME..."
    
    if [ ! -d "$HOMELAB_ENV_DIR" ]; then
        mkdir -p "$HOMELAB_ENV_DIR"
        log "Created directory: $HOMELAB_ENV_DIR"
    else
        info "Directory already exists: $HOMELAB_ENV_DIR"
    fi
}

# Copy .env.example to $HOME/.homelab/.env
copy_env_file() {
    log "Setting up .env file..."
    
    if [ ! -f "$HOMELAB_ENV_FILE" ]; then
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$HOMELAB_ENV_FILE"
            chmod 600 "$HOMELAB_ENV_FILE"
            log "Created .env file: $HOMELAB_ENV_FILE"
            warn "Please edit $HOMELAB_ENV_FILE with your settings!"
        else
            error ".env.example not found at $ENV_EXAMPLE"
        fi
    else
        info ".env file already exists: $HOMELAB_ENV_FILE"
        info "Skipping copy. Edit manually if needed."
    fi
}

# Create symlink in project directory (optional)
create_symlink() {
    local project_dir="$1"
    
    if [ "$project_dir" != "" ]; then
        local symlink_path="$project_dir/.env"
        
        if [ ! -f "$symlink_path" ]; then
            ln -s "$HOMELAB_ENV_FILE" "$symlink_path"
            log "Created symlink: $symlink_path -> $HOMELAB_ENV_FILE"
        else
            info "Symlink already exists: $symlink_path"
        fi
    fi
}

# Display setup summary
show_summary() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Homelab Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "  ${BLUE}Environment file:${NC}"
    echo "    $HOMELAB_ENV_FILE"
    echo ""
    echo -e "  ${BLUE}Next steps:${NC}"
    echo "    1. Edit the .env file:"
    echo "       nano $HOMELAB_ENV_FILE"
    echo ""
    echo "    2. Deploy the homelab:"
    echo "       cd $BASE_DIR"
    echo "       ./scripts/deploy.sh deploy"
    echo ""
    echo -e "  ${BLUE}Or deploy manually:${NC}"
    echo "       cd $BASE_DIR"
    echo "       docker compose --env-file $HOMELAB_ENV_FILE up -d"
    echo ""
    echo -e "${GREEN}========================================${NC}"
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --project-dir DIR  Create symlink in project directory"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                  # Basic setup"
    echo "  $0 -p /path/to/docker_homelab       # Setup with symlink"
}

# Main function
main() {
    local project_dir=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--project-dir)
                project_dir="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
    
    log "Starting homelab setup..."
    
    create_home_directory
    copy_env_file
    
    if [ "$project_dir" != "" ]; then
        create_symlink "$project_dir"
    fi
    
    show_summary
}

# Run main function
main "$@"