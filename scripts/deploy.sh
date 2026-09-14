#!/bin/bash
# Homelab deployment script
# Deploys the homelab using Ansible and OpenTofu

set -e

# Configuration
BASE_DIR="/home/runemal/Documents/docker_homelab"
ANSIBLE_DIR="$BASE_DIR/ansible"
TOFU_DIR="$BASE_DIR/tofu"

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

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        error "Docker Compose is not installed"
    fi
    
    # Check Ansible
    if ! command -v ansible &> /dev/null; then
        warn "Ansible is not installed. Installing..."
        sudo apt update && sudo apt install -y ansible
    fi
    
    # Check OpenTofu
    if ! command -v tofu &> /dev/null; then
        warn "OpenTofu is not installed. Please install OpenTofu first."
    fi
    
    log "Prerequisites check completed"
}

# Deploy with OpenTofu
deploy_tofu() {
    log "Deploying infrastructure with OpenTofu..."
    
    cd "$TOFU_DIR/environments/dev"
    
    tofu init
    tofu plan -out=tfplan
    tofu apply tfplan
    
    log "OpenTofu deployment completed"
}

# Deploy with Ansible
deploy_ansible() {
    log "Deploying services with Ansible..."
    
    cd "$ANSIBLE_DIR"
    
    # Run the main playbook
    ansible-playbook playbooks/site.yml -i inventory/hosts.yml
    
    log "Ansible deployment completed"
}

# Deploy with Docker Compose
deploy_docker() {
    log "Deploying services with Docker Compose..."
    
    cd "$BASE_DIR"
    
    # Copy environment file if it doesn't exist
    if [ ! -f .env ]; then
        cp .env.example .env
        warn "Created .env file from .env.example. Please customize it."
    fi
    
    # Collect all compose files (base-service.yml first for anchors)
    COMPOSE_FILES="-f docker-compose.yml -f services/base-service.yml"
    for f in services/*/docker-compose*.yml; do
        if [ -f "$f" ]; then
            COMPOSE_FILES="$COMPOSE_FILES -f $f"
        fi
    done
    
    # Deploy all services
    docker compose $COMPOSE_FILES up -d
    
    log "Docker Compose deployment completed"
}

# Run tests
run_tests() {
    log "Running tests..."
    
    cd "$BASE_DIR"
    
    # Run unit tests
    if command -v pytest &> /dev/null; then
        pytest tests/unit/ -v
    else
        warn "pytest not installed, skipping tests"
    fi
    
    log "Tests completed"
}

# Show deployment status
show_status() {
    log "Deployment status:"
    
    cd "$BASE_DIR"
    docker compose ps
    
    echo ""
    log "Service endpoints:"
    echo "  Traefik: http://localhost:8080"
    echo "  Portainer: http://localhost:9000"
    echo "  Prometheus: http://localhost:9090"
    echo "  Grafana: http://localhost:3000"
}

# Main execution
main() {
    local command="${1:-deploy}"
    
    case $command in
        "deploy")
            check_prerequisites
            deploy_tofu
            deploy_ansible
            deploy_docker
            run_tests
            show_status
            ;;
        "tofu")
            deploy_tofu
            ;;
        "ansible")
            deploy_ansible
            ;;
        "docker")
            deploy_docker
            ;;
        "test")
            run_tests
            ;;
        "status")
            show_status
            ;;
        "help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  deploy     - Deploy everything (default)"
            echo "  tofu       - Deploy with OpenTofu only"
            echo "  ansible    - Deploy with Ansible only"
            echo "  docker     - Deploy with Docker Compose only"
            echo "  test       - Run tests"
            echo "  status     - Show deployment status"
            echo "  help       - Show this help message"
            ;;
        *)
            error "Unknown command: $command"
            ;;
    esac
}

# Run main function
main "$@"