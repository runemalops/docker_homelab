#!/bin/bash
# Test runner script for homelab
# Runs all tests with proper configuration

set -e

# Configuration
BASE_DIR="/home/runemal/Documents/docker_homelab"
TEST_DIR="$BASE_DIR/tests"

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
    log "Checking test prerequisites..."
    
    # Check pytest
    if ! command -v pytest &> /dev/null; then
        warn "pytest not installed. Installing..."
        pip install pytest pytest-html pytest-cov
    fi
    
    # Check Python dependencies
    if [ -f "$BASE_DIR/requirements.txt" ]; then
        pip install -r "$BASE_DIR/requirements.txt"
    fi
    
    log "Prerequisites check completed"
}

# Run unit tests
run_unit_tests() {
    log "Running unit tests..."
    
    cd "$BASE_DIR"
    pytest tests/unit/ -v --tb=short
    
    log "Unit tests completed"
}

# Run integration tests
run_integration_tests() {
    log "Running integration tests..."
    
    cd "$BASE_DIR"
    pytest tests/integration/ -v --tb=short
    
    log "Integration tests completed"
}

# Run end-to-end tests
run_e2e_tests() {
    log "Running end-to-end tests..."
    
    cd "$BASE_DIR"
    pytest tests/e2e/ -v --tb=short
    
    log "End-to-end tests completed"
}

# Run all tests
run_all_tests() {
    log "Running all tests..."
    
    cd "$BASE_DIR"
    pytest tests/ -v --tb=short --html=reports/test_report.html --self-contained-html
    
    log "All tests completed"
    log "Test report generated at: reports/test_report.html"
}

# Run tests with coverage
run_tests_with_coverage() {
    log "Running tests with coverage..."
    
    cd "$BASE_DIR"
    pytest tests/ -v --tb=short --cov=. --cov-report=html:reports/coverage
    
    log "Tests with coverage completed"
    log "Coverage report generated at: reports/coverage/index.html"
}

# Main execution
main() {
    local command="${1:-all}"
    
    check_prerequisites
    
    case $command in
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "e2e")
            run_e2e_tests
            ;;
        "all")
            run_all_tests
            ;;
        "coverage")
            run_tests_with_coverage
            ;;
        "help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  unit         - Run unit tests only"
            echo "  integration  - Run integration tests only"
            echo "  e2e          - Run end-to-end tests only"
            echo "  all          - Run all tests (default)"
            echo "  coverage     - Run tests with coverage"
            echo "  help         - Show this help message"
            ;;
        *)
            error "Unknown command: $command"
            ;;
    esac
}

# Run main function
main "$@"