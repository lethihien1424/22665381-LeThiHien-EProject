#!/bin/bash

# Docker Health Check and Monitoring Script
# Usage: ./docker-health-check.sh [environment]

set -e

ENVIRONMENT=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Set compose file based on environment
case "$ENVIRONMENT" in
    "production")
        COMPOSE_FILE="docker-compose.prod.yml"
        ;;
    "staging")
        COMPOSE_FILE="docker-compose.staging.yml"
        ;;
    *)
        COMPOSE_FILE="Docker-compose.yml"
        ;;
esac

log_info "Checking health of services in $ENVIRONMENT environment..."
log_info "Using compose file: $COMPOSE_FILE"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running or not accessible"
    exit 1
fi

# Check if compose file exists
if [[ ! -f "$COMPOSE_FILE" ]]; then
    log_error "Docker Compose file $COMPOSE_FILE not found!"
    exit 1
fi

# Function to check container health
check_container_health() {
    local service=$1
    local container_id=$(docker-compose -f "$COMPOSE_FILE" ps -q "$service" 2>/dev/null)
    
    if [[ -z "$container_id" ]]; then
        log_error "$service: Container not found"
        return 1
    fi
    
    local status=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" 2>/dev/null || echo "no-healthcheck")
    local state=$(docker inspect --format='{{.State.Status}}' "$container_id" 2>/dev/null || echo "unknown")
    
    case "$status" in
        "healthy")
            log_success "$service: Healthy"
            return 0
            ;;
        "unhealthy")
            log_error "$service: Unhealthy"
            return 1
            ;;
        "starting")
            log_warning "$service: Starting (health check in progress)"
            return 0
            ;;
        "no-healthcheck")
            if [[ "$state" == "running" ]]; then
                log_warning "$service: Running (no health check configured)"
                return 0
            else
                log_error "$service: Not running (status: $state)"
                return 1
            fi
            ;;
        *)
            log_error "$service: Unknown health status ($status)"
            return 1
            ;;
    esac
}

# Function to check service connectivity
check_service_connectivity() {
    local service=$1
    local port=$2
    local path=${3:-"/health"}
    
    log_info "Checking connectivity for $service on port $port..."
    
    if curl -s -f "http://localhost:$port$path" > /dev/null 2>&1; then
        log_success "$service: Connectivity OK"
        return 0
    else
        log_error "$service: Connectivity failed on port $port$path"
        return 1
    fi
}

# Function to check resource usage
check_resource_usage() {
    log_info "Checking resource usage..."
    
    # Get running containers
    local containers=$(docker-compose -f "$COMPOSE_FILE" ps -q 2>/dev/null)
    
    if [[ -z "$containers" ]]; then
        log_warning "No containers found"
        return 0
    fi
    
    echo -e "\n${BLUE}Resource Usage:${NC}"
    printf "%-20s %-10s %-10s %-15s %-15s\n" "Container" "CPU %" "Memory %" "Memory Usage" "Net I/O"
    printf "%-20s %-10s %-10s %-15s %-15s\n" "--------" "-----" "--------" "------------" "------"
    
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $containers | tail -n +2 | while read line; do
        container_name=$(echo "$line" | awk '{print $1}' | cut -c1-19)
        cpu_percent=$(echo "$line" | awk '{print $2}')
        mem_percent=$(echo "$line" | awk '{print $3}')
        mem_usage=$(echo "$line" | awk '{print $4}')
        net_io=$(echo "$line" | awk '{print $5}')
        
        # Color code based on usage
        if [[ "${cpu_percent%.*}" -gt 80 ]] || [[ "${mem_percent%.*}" -gt 80 ]]; then
            printf "${RED}%-20s %-10s %-10s %-15s %-15s${NC}\n" "$container_name" "$cpu_percent" "$mem_percent" "$mem_usage" "$net_io"
        elif [[ "${cpu_percent%.*}" -gt 60 ]] || [[ "${mem_percent%.*}" -gt 60 ]]; then
            printf "${YELLOW}%-20s %-10s %-10s %-15s %-15s${NC}\n" "$container_name" "$cpu_percent" "$mem_percent" "$mem_usage" "$net_io"
        else
            printf "%-20s %-10s %-10s %-15s %-15s\n" "$container_name" "$cpu_percent" "$mem_percent" "$mem_usage" "$net_io"
        fi
    done
}

# Function to check logs for errors
check_service_logs() {
    local service=$1
    local lines=${2:-50}
    
    log_info "Checking recent logs for $service (last $lines lines)..."
    
    local error_count=$(docker-compose -f "$COMPOSE_FILE" logs --tail="$lines" "$service" 2>/dev/null | grep -i "error\|exception\|failed" | wc -l)
    local warning_count=$(docker-compose -f "$COMPOSE_FILE" logs --tail="$lines" "$service" 2>/dev/null | grep -i "warn" | wc -l)
    
    if [[ $error_count -gt 0 ]]; then
        log_error "$service: Found $error_count errors in recent logs"
    elif [[ $warning_count -gt 5 ]]; then
        log_warning "$service: Found $warning_count warnings in recent logs"
    else
        log_success "$service: No critical issues in recent logs"
    fi
}

# Main health check routine
main_health_check() {
    local overall_status=0
    
    echo -e "\n${BLUE}=== Docker Services Health Check ===${NC}\n"
    
    # Check infrastructure services
    log_info "Checking infrastructure services..."
    check_container_health "mongodb" || overall_status=1
    check_container_health "rabbitmq" || overall_status=1
    
    # Check application services
    log_info "Checking application services..."
    check_container_health "auth" || overall_status=1
    check_container_health "product" || overall_status=1
    check_container_health "order" || overall_status=1
    check_container_health "api-gateway" || overall_status=1
    
    # Check connectivity for application services
    echo -e "\n${BLUE}=== Connectivity Tests ===${NC}\n"
    check_service_connectivity "auth" "3000" || overall_status=1
    check_service_connectivity "product" "3001" || overall_status=1
    check_service_connectivity "order" "3002" || overall_status=1
    check_service_connectivity "api-gateway" "3003" || overall_status=1
    
    # Check monitoring services (if in production)
    if [[ "$ENVIRONMENT" == "production" ]]; then
        log_info "Checking monitoring services..."
        check_container_health "nginx"
        check_container_health "prometheus"
        check_container_health "grafana"
        check_service_connectivity "nginx" "80" "/"
        check_service_connectivity "prometheus" "9090"
        check_service_connectivity "grafana" "3004"
    fi
    
    # Resource usage check
    echo -e "\n${BLUE}=== Resource Usage ===${NC}\n"
    check_resource_usage
    
    # Log analysis
    echo -e "\n${BLUE}=== Log Analysis ===${NC}\n"
    check_service_logs "auth"
    check_service_logs "product"
    check_service_logs "order"
    check_service_logs "api-gateway"
    
    return $overall_status
}

# Run main health check
if main_health_check; then
    echo -e "\n${GREEN}=== Overall Status: HEALTHY ===${NC}"
    exit 0
else
    echo -e "\n${RED}=== Overall Status: UNHEALTHY ===${NC}"
    log_error "Some services are not healthy. Check the details above."
    exit 1
fi