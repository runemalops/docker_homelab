#!/usr/bin/env python3
"""
Unit tests for Docker Compose configurations
TDD approach: Tests written before implementation
"""

import pytest
import yaml
import os
from pathlib import Path


class TestDockerCompose:
    """Test Docker Compose configuration files"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.compose_files = {
            'base': self.base_path / 'docker-compose.yml',
            'monitoring': self.base_path / 'services' / 'monitoring' / 'docker-compose.monitoring.yml',
            'media': self.base_path / 'services' / 'media' / 'docker-compose.media.yml',
            'web': self.base_path / 'services' / 'web' / 'docker-compose.web.yml',
            'databases': self.base_path / 'services' / 'databases' / 'docker-compose.databases.yml',
            'networking': self.base_path / 'services' / 'networking' / 'docker-compose.networking.yml',
            'utilities': self.base_path / 'services' / 'utilities' / 'docker-compose.utilities.yml',
        }
    
    def test_base_compose_file_exists(self):
        """Test that base docker-compose.yml exists"""
        assert self.compose_files['base'].exists(), "Base docker-compose.yml not found"
    
    def test_base_compose_valid_yaml(self):
        """Test that base docker-compose.yml is valid YAML"""
        with open(self.compose_files['base']) as f:
            config = yaml.safe_load(f)
        assert 'version' in config, "Missing version in docker-compose.yml"
        assert 'services' in config, "Missing services in docker-compose.yml"
    
    def test_base_compose_has_required_services(self):
        """Test that base docker-compose.yml has required services"""
        with open(self.compose_files['base']) as f:
            config = yaml.safe_load(f)
        
        required_services = ['traefik', 'portainer', 'watchtower']
        for service in required_services:
            assert service in config['services'], f"Missing service: {service}"
    
    def test_traefik_configuration(self):
        """Test Traefik configuration is correct"""
        with open(self.compose_files['base']) as f:
            config = yaml.safe_load(f)
        
        traefik = config['services']['traefik']
        assert traefik['image'].startswith('traefik:'), "Traefik image should start with traefik:"
        assert '80:80' in traefik['ports'], "Traefik should expose port 80"
        assert '443:443' in traefik['ports'], "Traefik should expose port 443"
        assert '8080:8080' in traefik['ports'], "Traefik should expose port 8080"
    
    def test_portainer_configuration(self):
        """Test Portainer configuration is correct"""
        with open(self.compose_files['base']) as f:
            config = yaml.safe_load(f)
        
        portainer = config['services']['portainer']
        assert portainer['image'].startswith('portainer/'), "Portainer image should start with portainer/"
        assert '9000:9000' in portainer['ports'], "Portainer should expose port 9000"
    
    def test_monitoring_compose_valid(self):
        """Test monitoring docker-compose is valid"""
        with open(self.compose_files['monitoring']) as f:
            config = yaml.safe_load(f)
        
        assert 'services' in config, "Missing services in monitoring compose"
        required_services = ['prometheus', 'grafana', 'node-exporter']
        for service in required_services:
            assert service in config['services'], f"Missing monitoring service: {service}"
    
    def test_database_compose_valid(self):
        """Test database docker-compose is valid"""
        with open(self.compose_files['databases']) as f:
            config = yaml.safe_load(f)
        
        assert 'services' in config, "Missing services in database compose"
        required_services = ['postgres', 'redis', 'mariadb']
        for service in required_services:
            assert service in config['services'], f"Missing database service: {service}"
    
    def test_all_compose_files_have_networks(self):
        """Test that all compose files have network configuration"""
        for name, file_path in self.compose_files.items():
            if file_path.exists():
                with open(file_path) as f:
                    config = yaml.safe_load(f)
                assert 'networks' in config, f"Missing networks in {name} compose file"
    
    def test_environment_variables_consistency(self):
        """Test that environment variables are consistent across files"""
        env_file = self.base_path / '.env.example'
        if env_file.exists():
            with open(env_file) as f:
                env_content = f.read()
            
            # Check for required variables
            required_vars = ['DOMAIN', 'POSTGRES_USER', 'POSTGRES_PASSWORD']
            for var in required_vars:
                assert var in env_content, f"Missing required variable: {var}"


class TestServiceTemplates:
    """Test service templates and DRY principles"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.templates_path = self.base_path / 'ansible' / 'roles' / 'docker-compose' / 'templates'
    
    def test_template_files_exist(self):
        """Test that template files exist"""
        required_templates = ['env.j2', 'docker-compose.override.yml.j2']
        for template in required_templates:
            template_path = self.templates_path / template
            assert template_path.exists(), f"Missing template: {template}"
    
    def test_env_template_has_required_variables(self):
        """Test that env template has required variables"""
        env_template = self.templates_path / 'env.j2'
        with open(env_template) as f:
            content = f.read()
        
        required_vars = ['DOMAIN', 'POSTGRES_USER', 'POSTGRES_PASSWORD', 'REDIS_PASSWORD']
        for var in required_vars:
            assert var in content, f"Missing variable in env template: {var}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])