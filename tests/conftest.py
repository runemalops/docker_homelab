#!/usr/bin/env python3
"""
Pytest configuration for homelab tests
"""

import pytest
import os
from pathlib import Path


def pytest_configure(config):
    """Configure pytest markers"""
    config.addinivalue_line(
        "markers", "unit: Unit tests for individual components"
    )
    config.addinivalue_line(
        "markers", "integration: Integration tests for multiple components"
    )
    config.addinivalue_line(
        "markers", "e2e: End-to-end tests for complete workflows"
    )
    config.addinivalue_line(
        "markers", "slow: Tests that take a long time to run"
    )


def pytest_collection_modifyitems(config, items):
    """Modify test collection to handle markers"""
    if config.getoption("--runslow"):
        # --runslow given in cli: do not skip slow tests
        return
    skip_slow = pytest.mark.skip(reason="need --runslow option to run")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(skip_slow)


def pytest_addoption(parser):
    """Add custom command line options"""
    parser.addoption(
        "--runslow", action="store_true", default=False, help="run slow tests"
    )
    parser.addoption(
        "--environment", action="store", default="dev", help="test environment"
    )


@pytest.fixture(scope="session")
def base_path():
    """Get base path for the project"""
    return Path(__file__).parent.parent


@pytest.fixture(scope="session")
def environment(request):
    """Get test environment"""
    return request.config.getoption("--environment")


@pytest.fixture(scope="session")
def docker_host():
    """Get Docker host"""
    return os.getenv('DOCKER_HOST', 'unix:///var/run/docker.sock')


@pytest.fixture(scope="session")
def domain():
    """Get domain name"""
    return os.getenv('DOMAIN', 'localhost')


@pytest.fixture(scope="function")
def temp_dir(tmp_path):
    """Create temporary directory for tests"""
    return tmp_path


@pytest.fixture(scope="function")
def sample_compose_config():
    """Sample Docker Compose configuration for testing"""
    return {
        'version': '3.8',
        'services': {
            'test-service': {
                'image': 'nginx:alpine',
                'ports': ['8080:80'],
                'networks': ['test-network']
            }
        },
        'networks': {
            'test-network': {
                'driver': 'bridge'
            }
        }
    }


@pytest.fixture(scope="function")
def sample_ansible_vars():
    """Sample Ansible variables for testing"""
    return {
        'domain': 'localhost',
        'postgres_user': 'homelab',
        'postgres_password': 'testpassword',
        'enable_monitoring': True,
        'enable_databases': True
    }