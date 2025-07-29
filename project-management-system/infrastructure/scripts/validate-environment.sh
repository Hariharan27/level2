#!/bin/bash

# =============================================================================
# PROJECT MANAGEMENT SYSTEM - ENVIRONMENT VALIDATION SCRIPT
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is open
check_port() {
    local host=$1
    local port=$2
    local service=$3
    
    if nc -z "$host" "$port" 2>/dev/null; then
        print_status "SUCCESS" "$service is running on $host:$port"
        return 0
    else
        print_status "ERROR" "$service is not running on $host:$port"
        return 1
    fi
}

# Function to check HTTP endpoint
check_http_endpoint() {
    local url=$1
    local service=$2
    
    if curl -f -s "$url" >/dev/null 2>&1; then
        print_status "SUCCESS" "$service HTTP endpoint is accessible at $url"
        return 0
    else
        print_status "ERROR" "$service HTTP endpoint is not accessible at $url"
        return 1
    fi
}

# Function to check Docker container
check_docker_container() {
    local container=$1
    local service=$2
    
    if docker ps --format "table {{.Names}}" | grep -q "^$container$"; then
        local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
        if [ "$status" = "running" ]; then
            print_status "SUCCESS" "$service container ($container) is running"
            return 0
        else
            print_status "ERROR" "$service container ($container) is not running (status: $status)"
            return 1
        fi
    else
        print_status "ERROR" "$service container ($container) is not found"
        return 1
    fi
}

# Function to check environment file
check_env_file() {
    local env_file=$1
    
    if [ -f "$env_file" ]; then
        if [ -s "$env_file" ]; then
            print_status "SUCCESS" "Environment file $env_file exists and is not empty"
            return 0
        else
            print_status "WARNING" "Environment file $env_file exists but is empty"
            return 1
        fi
    else
        print_status "ERROR" "Environment file $env_file does not exist"
        return 1
    fi
}

# Function to check configuration files
check_config_files() {
    local config_dir=$1
    local config_name=$2
    
    if [ -f "$config_dir" ]; then
        print_status "SUCCESS" "$config_name configuration file exists"
        return 0
    else
        print_status "ERROR" "$config_name configuration file does not exist"
        return 1
    fi
}

# Main validation function
main() {
    echo "=============================================================================="
    echo "PROJECT MANAGEMENT SYSTEM - ENVIRONMENT VALIDATION"
    echo "=============================================================================="
    echo ""
    
    local errors=0
    local warnings=0
    
    # Check prerequisites
    print_status "INFO" "Checking prerequisites..."
    
    if command_exists docker; then
        print_status "SUCCESS" "Docker is installed"
    else
        print_status "ERROR" "Docker is not installed"
        ((errors++))
    fi
    
    if command_exists docker-compose; then
        print_status "SUCCESS" "Docker Compose is installed"
    else
        print_status "ERROR" "Docker Compose is not installed"
        ((errors++))
    fi
    
    if command_exists curl; then
        print_status "SUCCESS" "curl is installed"
    else
        print_status "ERROR" "curl is not installed"
        ((errors++))
    fi
    
    if command_exists nc; then
        print_status "SUCCESS" "netcat is installed"
    else
        print_status "WARNING" "netcat is not installed (port checking will be limited)"
        ((warnings++))
    fi
    
    echo ""
    
    # Check configuration files
    print_status "INFO" "Checking configuration files..."
    
    if check_config_files "docker-compose.yml" "Docker Compose"; then
        print_status "SUCCESS" "Docker Compose configuration is valid"
    else
        ((errors++))
    fi
    
    if check_config_files "config/kong.yml" "Kong API Gateway"; then
        print_status "SUCCESS" "Kong configuration is valid"
    else
        ((errors++))
    fi
    
    if check_config_files "config/prometheus.yml" "Prometheus"; then
        print_status "SUCCESS" "Prometheus configuration is valid"
    else
        ((errors++))
    fi
    
    if check_config_files "frontend/package.json" "Frontend"; then
        print_status "SUCCESS" "Frontend package configuration is valid"
    else
        ((errors++))
    fi
    
    if check_config_files "frontend/Dockerfile" "Frontend Docker"; then
        print_status "SUCCESS" "Frontend Dockerfile is valid"
    else
        ((errors++))
    fi
    
    echo ""
    
    # Check environment files
    print_status "INFO" "Checking environment files..."
    
    if check_env_file ".env"; then
        print_status "SUCCESS" "Environment file is configured"
    else
        print_status "WARNING" "Please copy env.example to .env and configure it"
        ((warnings++))
    fi
    
    echo ""
    
    # Check if services are running
    print_status "INFO" "Checking if services are running..."
    
    # Check Docker containers
    local containers=(
        "api-gateway:API Gateway"
        "auth-service:Authentication Service"
        "user-service:User Service"
        "project-service:Project Service"
        "task-service:Task Service"
        "time-service:Time Service"
        "file-service:File Service"
        "comment-service:Comment Service"
        "notification-service:Notification Service"
        "analytics-service:Analytics Service"
        "frontend:Frontend"
        "redis:Redis"
        "rabbitmq:RabbitMQ"
        "elasticsearch:Elasticsearch"
        "prometheus:Prometheus"
        "grafana:Grafana"
        "minio:MinIO"
    )
    
    for container_info in "${containers[@]}"; do
        IFS=':' read -r container service <<< "$container_info"
        if ! check_docker_container "$container" "$service"; then
            ((errors++))
        fi
    done
    
    echo ""
    
    # Check service endpoints (if containers are running)
    print_status "INFO" "Checking service endpoints..."
    
    local endpoints=(
        "http://localhost:8000/health:API Gateway"
        "http://localhost:8001/health:Auth Service"
        "http://localhost:8002/health:User Service"
        "http://localhost:8003/health:Project Service"
        "http://localhost:8004/health:Task Service"
        "http://localhost:8005/health:Time Service"
        "http://localhost:8006/health:File Service"
        "http://localhost:8007/health:Comment Service"
        "http://localhost:8008/health:Notification Service"
        "http://localhost:8009/health:Analytics Service"
        "http://localhost:3000:Frontend"
        "http://localhost:9090:Prometheus"
        "http://localhost:3001:Grafana"
        "http://localhost:15672:RabbitMQ Management"
        "http://localhost:9001:MinIO Console"
        "http://localhost:9200:Elasticsearch"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS=':' read -r url service <<< "$endpoint_info"
        if ! check_http_endpoint "$url" "$service"; then
            ((errors++))
        fi
    done
    
    echo ""
    
    # Check database connections
    print_status "INFO" "Checking database connections..."
    
    local databases=(
        "auth-db:5432:Auth Database"
        "user-db:5432:User Database"
        "project-db:5432:Project Database"
        "task-db:5432:Task Database"
        "time-db:5432:Time Database"
        "comment-db:5432:Comment Database"
        "analytics-db:5432:Analytics Database"
    )
    
    for db_info in "${databases[@]}"; do
        IFS=':' read -r host port service <<< "$db_info"
        if ! check_port "$host" "$port" "$service"; then
            ((errors++))
        fi
    done
    
    echo ""
    
    # Summary
    echo "=============================================================================="
    echo "VALIDATION SUMMARY"
    echo "=============================================================================="
    
    if [ $errors -eq 0 ]; then
        print_status "SUCCESS" "All critical checks passed! Your environment is ready."
        if [ $warnings -gt 0 ]; then
            print_status "WARNING" "There are $warnings warnings that should be addressed."
        fi
        echo ""
        print_status "INFO" "You can now start developing your project management system!"
        print_status "INFO" "Frontend: http://localhost:3000"
        print_status "INFO" "API Gateway: http://localhost:8000"
        print_status "INFO" "Grafana: http://localhost:3001"
        print_status "INFO" "Prometheus: http://localhost:9090"
        exit 0
    else
        print_status "ERROR" "Found $errors errors that need to be fixed before proceeding."
        if [ $warnings -gt 0 ]; then
            print_status "WARNING" "There are also $warnings warnings to address."
        fi
        echo ""
        print_status "INFO" "Please fix the errors above and run this script again."
        exit 1
    fi
}

# Run main function
main "$@" 