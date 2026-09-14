# Homelab Infrastructure

A production-ready homelab infrastructure managed with Docker, Ansible, and OpenTofu, following DRY principles and Test Driven Development.

## Architecture

```
docker_homelab/
├── base/                          # Base configurations
├── services/                      # Service-specific configurations
│   ├── monitoring/               # Prometheus, Grafana, Node Exporter
│   ├── media/                    # Plex, Sonarr, Radarr, qBittorrent
│   ├── web/                      # Nginx, Nextcloud, WordPress
│   ├── databases/                # PostgreSQL, Redis, MariaDB
│   ├── networking/               # Pi-hole, WireGuard, Nginx Proxy Manager
│   └── utilities/                # Homepage, Gitea, Vaultwarden, Uptime Kuma
├── ansible/                       # Ansible playbooks and roles
│   ├── roles/                    # Reusable Ansible roles
│   ├── playbooks/                # Main playbooks
│   ├── group_vars/               # Group variables
│   └── inventory/                # Inventory files
├── tofu/                           # OpenTofu configurations
│   ├── modules/                  # Reusable OpenTofu modules
│   └── environments/             # Environment-specific configs
├── tests/                         # Test suites
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── e2e/                      # End-to-end tests
├── scripts/                       # Utility scripts
├── configs/                       # Configuration files
├── docker-compose.yml             # Main Docker Compose file
├── .env.example                   # Environment variables template
└── README.md                      # This file
```

## Features

- **DRY Principles**: Shared configurations, templates, and reusable modules
- **Test Driven Development**: Comprehensive test suite with unit, integration, and e2e tests
- **Security First**: Firewall, Fail2Ban, and security hardening
- **Monitoring**: Full observability with Prometheus and Grafana
- **Automated Deployment**: Ansible for configuration management
- **Infrastructure as Code**: OpenTofu for infrastructure provisioning
- **Auto-updates**: Watchtower for automatic container updates
- **Reverse Proxy**: Traefik for SSL termination and routing

## Prerequisites

- Docker and Docker Compose
- Ansible (for configuration management)
- OpenTofu (for infrastructure provisioning)
- Python 3.8+ (for testing)

## Quick Start

### Option 1: Local Deployment (Recommended)

The `.env` file is stored in `$HOME/.homelab/.env` for security and separation from the repository.

```bash
git clone <repository-url>
cd docker_homelab

# Run setup script - creates .env in $HOME/.homelab/
./scripts/setup.sh

# Edit the .env file with your settings
nano ~/.homelab/.env

# Deploy with Docker Compose (reads .env from $HOME)
docker compose --env-file ~/.homelab/.env up -d
```

### Option 2: Project-Local .env

If you prefer `.env` in the project directory:

```bash
git clone <repository-url>
cd docker_homelab

# Run setup with project directory symlink
./scripts/setup.sh -p .

# Edit the .env file
nano ~/.homelab/.env

# Deploy
docker compose up -d
```

### Option 3: Deploy with Scripts

```bash
# Deploy everything (Ansible + OpenTofu + Docker)
./scripts/deploy.sh deploy

# Or deploy step by step
./scripts/deploy.sh tofu
./scripts/deploy.sh ansible
./scripts/deploy.sh docker
```

### Option 4: Manual Deployment

```bash
# Deploy infrastructure with OpenTofu
cd tofu/environments/dev
tofu init
tofu plan
tofu apply

# Configure services with Ansible
cd ansible
ansible-playbook playbooks/site.yml

# Start services with Docker Compose
cd ..
docker compose --env-file ~/.homelab/.env up -d
```

## Services

### Core Services (Always Running)

- **Traefik**: Reverse proxy and SSL termination
- **Portainer**: Container management UI
- **Watchtower**: Automatic container updates

### Monitoring Stack

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Dashboards and visualization
- **Node Exporter**: System metrics

### Optional Services

- **Databases**: PostgreSQL, Redis, MariaDB
- **Networking**: Pi-hole, WireGuard, Nginx Proxy Manager
- **Web**: Nginx, Nextcloud, WordPress
- **Media**: Plex, Sonarr, Radarr, qBittorrent
- **Utilities**: Homepage, Gitea, Vaultwarden, Uptime Kuma

## Testing

### Running Tests

```bash
# Run all tests
./scripts/run_tests.sh all

# Run specific test types
./scripts/run_tests.sh unit
./scripts/run_tests.sh integration
./scripts/run_tests.sh e2e

# Run with coverage
./scripts/run_tests.sh coverage
```

### Test Structure

- **Unit Tests**: Test individual components and configurations
- **Integration Tests**: Test Ansible roles and OpenTofu modules
- **E2E Tests**: Test complete deployment and service health

## Configuration

### Environment Variables

The `.env` file is stored in `$HOME/.homelab/.env` (outside the repository for security).

**Setup:**
```bash
# Run setup script
./scripts/setup.sh

# Or manually create
mkdir -p ~/.homelab
cp .env.example ~/.homelab/.env
chmod 600 ~/.homelab/.env
nano ~/.homelab/.env
```

**Location:**
```
$HOME/
└── .homelab/
    └── .env          # Your configuration (not in git)
```

**Key Variables:**
```bash
DOMAIN=yourdomain.com
POSTGRES_PASSWORD=your-secure-password
GRAFANA_ADMIN_PASSWORD=your-grafana-password
```

### Ansible Variables

Edit `ansible/group_vars/all.yml` to customize:

```yaml
domain: "yourdomain.com"
enable_monitoring: true
enable_databases: true
```

### OpenTofu Variables

Edit `tofu/environments/dev/variables.tf` or create a `terraform.tfvars` file.

## Development

### Adding New Services

1. Create a new directory in `services/`
2. Add `docker-compose.<service>.yml`
3. Update Ansible roles if needed
4. Add tests for the new service
5. Update documentation

### TDD Workflow

1. Write tests first
2. Run tests to ensure they fail
3. Implement the feature
4. Run tests to ensure they pass
5. Refactor if needed

### Code Style

- Follow existing patterns and conventions
- Use templates and variables to avoid repetition
- Write comprehensive tests
- Document changes in README

## Backup

```bash
# Run backup script
./scripts/backup.sh

# Backup location: /var/backups/homelab/
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports are already in use
2. **Permission issues**: Ensure proper file permissions
3. **Network issues**: Verify Docker networks are created

### Logs

```bash
# View service logs
docker compose logs <service-name>

# View all logs
docker compose logs -f
```

### Health Checks

```bash
# Check service status
docker compose ps

# Check specific service
curl http://localhost:8080/api/overview  # Traefik
curl http://localhost:9000/api/status    # Portainer
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Implement changes
5. Ensure all tests pass
6. Submit a pull request

## License

MIT License - see LICENSE file for details