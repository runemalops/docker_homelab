# Homelab Makefile
# Common operations for the homelab infrastructure

.PHONY: help deploy test clean backup status

# Default target
help: ## Show this help message
	@echo "Homelab Infrastructure Management"
	@echo "================================="
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Deployment
deploy: ## Deploy everything
	@./scripts/deploy.sh deploy

deploy-tofu: ## Deploy with OpenTofu only
	@./scripts/deploy.sh tofu

deploy-ansible: ## Deploy with Ansible only
	@./scripts/deploy.sh ansible

deploy-docker: ## Deploy with Docker Compose only
	@./scripts/deploy.sh docker

# Testing
test: ## Run all tests
	@./scripts/run_tests.sh all

test-unit: ## Run unit tests only
	@./scripts/run_tests.sh unit

test-integration: ## Run integration tests only
	@./scripts/run_tests.sh integration

test-e2e: ## Run end-to-end tests only
	@./scripts/run_tests.sh e2e

test-coverage: ## Run tests with coverage
	@./scripts/run_tests.sh coverage

# Utilities
backup: ## Run backup script
	@./scripts/backup.sh

status: ## Show deployment status
	@./scripts/deploy.sh status

logs: ## Show service logs
	@docker compose $(COMPOSE_FILES) logs -f

logs-service: ## Show specific service logs (usage: make logs-service service=traefik)
	@docker compose $(COMPOSE_FILES) logs -f $(service)

# Maintenance
clean: ## Clean up temporary files and caches
	@find . -type d -name __pycache__ -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name ".pytest_cache" -exec rm -rf {} +
	@find . -type d -name "htmlcov" -exec rm -rf {} +
	@find . -type f -name "*.tfstate*" -delete
	@find . -type f -name "*.tfplan" -delete

update: ## Update all containers
	@docker compose $(COMPOSE_FILES) pull
	@docker compose $(COMPOSE_FILES) up -d

restart: ## Restart all services
	@docker compose $(COMPOSE_FILES) restart

stop: ## Stop all services
	@docker compose $(COMPOSE_FILES) down

start: ## Start all services
	@docker compose $(COMPOSE_FILES) up -d

# Linting
lint: ## Run linting checks
	@echo "Running Python linting..."
	@black --check .
	@flake8 .
	@echo "Running Ansible linting..."
	@ansible-lint ansible/
	@echo "Running OpenTofu linting..."
	@cd tofu/environments/dev && tofu validate

format: ## Format code
	@echo "Formatting Python code..."
	@black .
	@isort .
	@echo "Formatting complete"

# Security
security-scan: ## Run security scans
	@echo "Running bandit security scan..."
	@bandit -r . -f json -o reports/security-report.json || true
	@echo "Running safety check..."
	@safety check --full-report

# Documentation
docs: ## Generate documentation
	@echo "Documentation is in README.md"

# Docker operations
COMPOSE_FILES=-f docker-compose.yml -f services/base-service.yml $(shell for f in services/*/docker-compose*.yml; do [ -f "$$f" ] && echo "-f $$f"; done)

ps: ## Show running containers
	@docker compose $(COMPOSE_FILES) ps

build: ## Build services
	@docker compose $(COMPOSE_FILES) build

pull: ## Pull latest images
	@docker compose $(COMPOSE_FILES) pull

# Ansible operations
ansible-lint: ## Run Ansible lint
	@ansible-lint ansible/

ansible-check: ## Check Ansible playbook
	@cd ansible && ansible-playbook playbooks/site.yml --check

# OpenTofu operations
tofu-init: ## Initialize OpenTofu
	@cd tofu/environments/dev && tofu init

tofu-plan: ## Plan OpenTofu changes
	@cd tofu/environments/dev && tofu plan

tofu-apply: ## Apply OpenTofu changes
	@cd tofu/environments/dev && tofu apply

tofu-destroy: ## Destroy OpenTofu infrastructure
	@cd tofu/environments/dev && tofu destroy