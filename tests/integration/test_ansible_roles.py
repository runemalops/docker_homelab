#!/usr/bin/env python3
"""
Integration tests for Ansible roles
TDD approach: Tests written before implementation
"""

import pytest
import yaml
import os
from pathlib import Path
import subprocess


class TestAnsibleRoles:
    """Test Ansible role structure and configurations"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.ansible_path = self.base_path / 'ansible'
        self.roles_path = self.ansible_path / 'roles'
    
    def test_ansible_directory_structure(self):
        """Test that Ansible directory structure is correct"""
        required_dirs = ['roles', 'playbooks', 'group_vars', 'inventory']
        for dir_name in required_dirs:
            dir_path = self.ansible_path / dir_name
            assert dir_path.exists(), f"Missing Ansible directory: {dir_name}"
    
    def test_roles_exist(self):
        """Test that required roles exist"""
        required_roles = ['docker', 'docker-compose', 'homelab-services', 'security', 'monitoring']
        for role in required_roles:
            role_path = self.roles_path / role
            assert role_path.exists(), f"Missing role: {role}"
    
    def test_roles_have_tasks(self):
        """Test that all roles have tasks directory"""
        for role_dir in self.roles_path.iterdir():
            if role_dir.is_dir():
                tasks_dir = role_dir / 'tasks'
                assert tasks_dir.exists(), f"Role {role_dir.name} missing tasks directory"
                main_yml = tasks_dir / 'main.yml'
                assert main_yml.exists(), f"Role {role_dir.name} missing main.yml tasks"
    
    def test_roles_have_handlers(self):
        """Test that roles that need handlers have them"""
        roles_needing_handlers = ['docker', 'security', 'monitoring']
        for role in roles_needing_handlers:
            handlers_dir = self.roles_path / role / 'handlers'
            assert handlers_dir.exists(), f"Role {role} missing handlers directory"
            main_yml = handlers_dir / 'main.yml'
            assert main_yml.exists(), f"Role {role} missing main.yml handlers"
    
    def test_docker_role_installs_packages(self):
        """Test that Docker role installs required packages"""
        docker_tasks = self.roles_path / 'docker' / 'tasks' / 'main.yml'
        with open(docker_tasks) as f:
            content = f.read()
        
        required_packages = ['docker-ce', 'docker-ce-cli', 'containerd.io']
        for package in required_packages:
            assert package in content, f"Docker role missing package: {package}"
    
    def test_security_role_configures_firewall(self):
        """Test that security role configures firewall"""
        security_tasks = self.roles_path / 'security' / 'tasks' / 'main.yml'
        with open(security_tasks) as f:
            content = f.read()
        
        assert 'ufw' in content, "Security role should configure UFW"
        assert 'fail2ban' in content, "Security role should configure Fail2Ban"
    
    def test_monitoring_role_configures_prometheus(self):
        """Test that monitoring role configures Prometheus"""
        monitoring_tasks = self.roles_path / 'monitoring' / 'tasks' / 'main.yml'
        with open(monitoring_tasks) as f:
            content = f.read()
        
        assert 'prometheus' in content, "Monitoring role should configure Prometheus"
        assert 'grafana' in content, "Monitoring role should configure Grafana"
    
    def test_group_vars_has_required_variables(self):
        """Test that group_vars has required variables"""
        group_vars = self.ansible_path / 'group_vars' / 'all.yml'
        with open(group_vars) as f:
            config = yaml.safe_load(f)
        
        required_vars = ['domain', 'postgres_user', 'postgres_password', 'enable_monitoring']
        for var in required_vars:
            assert var in config, f"Missing variable in group_vars: {var}"
    
    def test_inventory_has_localhost(self):
        """Test that inventory has localhost configured"""
        inventory = self.ansible_path / 'inventory' / 'hosts.yml'
        with open(inventory) as f:
            config = yaml.safe_load(f)
        
        assert 'all' in config, "Inventory missing 'all' group"
        assert 'hosts' in config['all'], "Inventory missing 'hosts' in 'all' group"
        assert 'localhost' in config['all']['hosts'], "Inventory missing localhost"


class TestAnsiblePlaybooks:
    """Test Ansible playbooks"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.playbooks_path = self.base_path / 'ansible' / 'playbooks'
    
    def test_main_playbook_exists(self):
        """Test that main playbook exists"""
        main_playbook = self.playbooks_path / 'site.yml'
        assert main_playbook.exists(), "Main playbook site.yml not found"
    
    def test_main_playbook_has_roles(self):
        """Test that main playbook has required roles"""
        with open(self.playbooks_path / 'site.yml') as f:
            config = yaml.safe_load(f)
        
        assert 'roles' in config[0], "Main playbook missing roles"
        role_names = [role['role'] for role in config[0]['roles']]
        required_roles = ['docker', 'docker-compose', 'security', 'homelab-services']
        for role in required_roles:
            assert role in role_names, f"Main playbook missing role: {role}"


class TestAnsibleLint:
    """Test Ansible lint rules"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.base_path = Path(__file__).parent.parent.parent
        self.ansible_path = self.base_path / 'ansible'
    
    def test_ansible_lint_installed(self):
        """Test that ansible-lint is installed"""
        result = subprocess.run(['ansible-lint', '--version'], 
                              capture_output=True, text=True)
        assert result.returncode == 0, "ansible-lint is not installed"
    
    def test_ansible_lint_passes(self):
        """Test that Ansible code passes lint checks"""
        result = subprocess.run(['ansible-lint', str(self.ansible_path)],
                              capture_output=True, text=True)
        # This test will fail initially, which is expected in TDD
        # The goal is to fix lint issues as we develop
        assert result.returncode == 0, f"Ansible lint failed:\n{result.stderr}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])