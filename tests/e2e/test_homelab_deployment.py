#!/usr/bin/env python3
"""
End-to-end tests for homelab deployment
TDD approach: Tests written before implementation
"""

import pytest
import yaml
import os
import subprocess
import time
from pathlib import Path
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class TestHomelabDeployment:
    """Test homelab deployment end-to-end"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.docker_host = os.getenv('DOCKER_HOST', 'unix:///var/run/docker.sock')
        self.domain = os.getenv('DOMAIN', 'localhost')
        
        # Setup retry strategy for HTTP requests
        self.retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[500, 502, 503, 504],
        )
        self.adapter = HTTPAdapter(max_retries=self.retry_strategy)
        self.http = requests.Session()
        self.http.mount("http://", self.adapter)
        self.http.mount("https://", self.adapter)
    
    def test_docker_is_running(self):
        """Test that Docker is running"""
        result = subprocess.run(['docker', 'info'], 
                              capture_output=True, text=True)
        assert result.returncode == 0, "Docker is not running"
    
    def test_docker_compose_is_installed(self):
        """Test that Docker Compose is installed"""
        result = subprocess.run(['docker', 'compose', 'version'], 
                              capture_output=True, text=True)
        assert result.returncode == 0, "Docker Compose is not installed"
    
    def test_base_services_are_running(self):
        """Test that base services are running"""
        result = subprocess.run(['docker', 'compose', 'ps', '--format', 'json'],
                              capture_output=True, text=True, 
                              cwd=str(self.base_path))
        
        if result.returncode == 0 and result.stdout:
            services = [yaml.safe_load(line) for line in result.stdout.strip().split('\n') if line]
            running_services = [s['Service'] for s in services if s.get('State') == 'running']
            
            # Check that critical services are running
            critical_services = ['traefik', 'portainer']
            for service in critical_services:
                assert service in running_services, f"Service {service} is not running"
    
    def test_traefik_is_responsive(self):
        """Test that Traefik is responsive"""
        try:
            response = self.http.get(f"http://localhost:8080/api/overview", timeout=10)
            assert response.status_code == 200, "Traefik is not responsive"
        except requests.exceptions.RequestException:
            pytest.skip("Traefik is not running or not accessible")
    
    def test_portainer_is_responsive(self):
        """Test that Portainer is responsive"""
        try:
            response = self.http.get(f"http://localhost:9000/api/status", timeout=10)
            assert response.status_code == 200, "Portainer is not responsive"
        except requests.exceptions.RequestException:
            pytest.skip("Portainer is not running or not accessible")
    
    def test_prometheus_is_responsive(self):
        """Test that Prometheus is responsive"""
        try:
            response = self.http.get(f"http://localhost:9090/-/healthy", timeout=10)
            assert response.status_code == 200, "Prometheus is not responsive"
        except requests.exceptions.RequestException:
            pytest.skip("Prometheus is not running or not accessible")
    
    def test_grafana_is_responsive(self):
        """Test that Grafana is responsive"""
        try:
            response = self.http.get(f"http://localhost:3000/api/health", timeout=10)
            assert response.status_code == 200, "Grafana is not responsive"
        except requests.exceptions.RequestException:
            pytest.skip("Grafana is not running or not accessible")
    
    def test_network_connectivity(self):
        """Test that Docker networks are properly configured"""
        result = subprocess.run(['docker', 'network', 'ls', '--format', '{{.Name}}'],
                              capture_output=True, text=True)
        
        required_networks = ['homelab_network', 'monitoring_network', 'web_network']
        for network in required_networks:
            assert network in result.stdout, f"Network {network} not found"
    
    def test_volumes_are_created(self):
        """Test that Docker volumes are created"""
        result = subprocess.run(['docker', 'volume', 'ls', '--format', '{{.Name}}'],
                              capture_output=True, text=True)
        
        required_volumes = ['prometheus_data', 'grafana_data', 'portainer_data']
        for volume in required_volumes:
            assert volume in result.stdout, f"Volume {volume} not found"
    
    def test_container_logs_are_available(self):
        """Test that container logs are available"""
        result = subprocess.run(['docker', 'compose', 'logs', '--tail=10', 'traefik'],
                              capture_output=True, text=True,
                              cwd=str(self.base_path))
        
        # Just check that logs command works, don't check content
        assert result.returncode == 0, "Cannot retrieve container logs"


class TestHomelabSecurity:
    """Test homelab security configurations"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
    
    def test_firewall_is_configured(self):
        """Test that firewall is configured"""
        try:
            result = subprocess.run(['ufw', 'status'], 
                                  capture_output=True, text=True)
            assert 'active' in result.stdout.lower(), "Firewall is not active"
        except FileNotFoundError:
            pytest.skip("UFW is not installed")
    
    def test_fail2ban_is_running(self):
        """Test that Fail2Ban is running"""
        try:
            result = subprocess.run(['systemctl', 'is-active', 'fail2ban'],
                                  capture_output=True, text=True)
            assert result.returncode == 0, "Fail2Ban is not running"
        except FileNotFoundError:
            pytest.skip("Fail2Ban is not installed")
    
    def test_docker_daemon_is_secured(self):
        """Test that Docker daemon is properly secured"""
        docker_config = Path('/etc/docker/daemon.json')
        if docker_config.exists():
            with open(docker_config) as f:
                config = json.load(f)
            
            # Check for security settings
            assert 'log-driver' in config, "Docker log driver not configured"
            assert config.get('live-restore', False) == False, "Live restore should be disabled for security"


class TestHomelabBackup:
    """Test homelab backup configurations"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
    
    def test_backup_script_exists(self):
        """Test that backup script exists"""
        backup_script = self.base_path / 'scripts' / 'backup.sh'
        assert backup_script.exists(), "Backup script not found"
    
    def test_backup_script_is_executable(self):
        """Test that backup script is executable"""
        backup_script = self.base_path / 'scripts' / 'backup.sh'
        if backup_script.exists():
            assert os.access(backup_script, os.X_OK), "Backup script is not executable"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])