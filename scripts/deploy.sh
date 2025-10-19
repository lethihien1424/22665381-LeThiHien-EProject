#!/bin/bash

# Enhanced Docker Deployment Script
# Usage: ./deploy.sh [staging|production] [version]

set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    log_error "Invalid environment. Use 'staging' or 'production'"
    exit 1
fi

# Set compose file based on environment
if [[ "$ENVIRONMENT" == "production" ]]; then
    COMPOSE_FILE="docker-compose.prod.yml"
    ENV_FILE=".env.prod"
else
    COMPOSE_FILE="docker-compose.staging.yml"
    ENV_FILE=".env.staging"
fi

log_info "Starting deployment to $ENVIRONMENT environment..."
log_info "Using Docker Compose file: $COMPOSE_FILE"
log_info "Version: $VERSION"

# Check if compose file exists
if [[ ! -f "$COMPOSE_FILE" ]]; then
    log_error "Docker Compose file $COMPOSE_FILE not found!"
    exit 1
fi

# Check if env file exists
if [[ ! -f "$ENV_FILE" ]]; then
    log_warning "Environment file $ENV_FILE not found, using defaults"
fi

# Export environment variables
export VERSION=$VERSION
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
fi

# Function to check service health
check_service_health() {
    local service=$1
    local max_attempts=30
    local attempt=1
    
    log_info "Checking health of $service service..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose -f "$COMPOSE_FILE" ps "$service" | grep -q "healthy\|Up"; then
            log_success "$service is healthy"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: $service not ready, waiting..."
        sleep 10
        ((attempt++))
    done
    
    log_error "$service failed health check after $max_attempts attempts"
    return 1
}

# Function to rollback deployment
rollback_deployment() {
    log_warning "Rolling back deployment..."
    
    if [[ -f "docker-compose.backup.yml" ]]; then
        log_info "Restoring from backup..."
        docker-compose -f docker-compose.backup.yml up -d
        log_success "Rollback completed"
    else
        log_error "No backup found for rollback"
    fi
}

# Trap errors and rollback
trap 'log_error "Deployment failed! Rolling back..."; rollback_deployment; exit 1' ERR

# Create backup of current deployment
log_info "Creating backup of current deployment..."
if docker-compose -f "$COMPOSE_FILE" ps -q > /dev/null 2>&1; then
    docker-compose -f "$COMPOSE_FILE" config > docker-compose.backup.yml
    log_success "Backup created"
fi

# Pull latest images
log_info "Pulling latest Docker images..."
docker-compose -f "$COMPOSE_FILE" pull

# Stop services gracefully
log_info "Stopping services gracefully..."
docker-compose -f "$COMPOSE_FILE" down --timeout 30

# Start infrastructure services first
log_info "Starting infrastructure services..."
docker-compose -f "$COMPOSE_FILE" up -d mongodb rabbitmq

# Wait for infrastructure to be ready
sleep 20
check_service_health "mongodb"
check_service_health "rabbitmq"

# Start application services
log_info "Starting application services..."
docker-compose -f "$COMPOSE_FILE" up -d auth product order

# Wait for application services
sleep 30
check_service_health "auth"
check_service_health "product" 
check_service_health "order"

# Start API Gateway
log_info "Starting API Gateway..."
docker-compose -f "$COMPOSE_FILE" up -d api-gateway

# Final health check
sleep 20
check_service_health "api-gateway"

# Start monitoring services if in production
if [[ "$ENVIRONMENT" == "production" ]]; then
    log_info "Starting monitoring services..."
    docker-compose -f "$COMPOSE_FILE" up -d nginx prometheus grafana
    sleep 15
fi

# Run smoke tests
log_info "Running smoke tests..."
if [[ "$ENVIRONMENT" == "production" ]]; then
    curl -f http://localhost/health || (log_error "Smoke tests failed"; exit 1)
else
    curl -f http://localhost:3003/health || (log_error "Smoke tests failed"; exit 1)
fi

# Clean up old images
log_info "Cleaning up old Docker images..."
docker image prune -f

# Remove backup on successful deployment
rm -f docker-compose.backup.yml

log_success "Deployment to $ENVIRONMENT completed successfully!"
log_info "Services are running:"
docker-compose -f "$COMPOSE_FILE" ps