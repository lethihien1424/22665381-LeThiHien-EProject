# Enhanced Docker CI/CD Setup

This project now includes a comprehensive Docker-based CI/CD pipeline with advanced features for microservices deployment, monitoring, and management.

## 🚀 Features

### CI/CD Pipeline
- **Smart Change Detection**: Only builds services that have changed
- **Multi-Platform Support**: Builds for both AMD64 and ARM64 architectures
- **Comprehensive Testing**: Unit tests, integration tests with real Docker containers
- **Security Scanning**: Trivy vulnerability scanning for Docker images
- **Rolling Deployments**: Zero-downtime deployments with health checks
- **Automatic Rollback**: Fails safely with automatic rollback capabilities

### Docker Configurations
- **Development**: `Docker-compose.yml` - Full local development environment
- **Staging**: `docker-compose.staging.yml` - Staging environment with basic monitoring
- **Production**: `docker-compose.prod.yml` - Production-ready with full monitoring, resource limits, and logging

### Monitoring & Observability
- **Health Checks**: Comprehensive health monitoring for all services
- **Resource Monitoring**: CPU, Memory, and Network usage tracking
- **Centralized Logging**: JSON-structured logging with rotation
- **Prometheus Metrics**: Application and infrastructure metrics
- **Grafana Dashboards**: Visual monitoring and alerting

## 📋 Prerequisites

1. **Docker & Docker Compose**
   ```bash
   # Install Docker (Ubuntu/Debian)
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **GitHub Secrets Configuration**
   Set up the following secrets in your GitHub repository:
   
   ```
   # Docker Hub
   DOCKER_USERNAME=your-dockerhub-username
   DOCKER_PASSWORD=your-dockerhub-token
   
   # Staging Server
   STAGING_HOST=staging.example.com
   STAGING_USER=deploy
   STAGING_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
   STAGING_URL=http://staging.example.com
   
   # Production Server
   PRODUCTION_HOST=production.example.com
   PRODUCTION_USER=deploy
   PRODUCTION_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
   PRODUCTION_URL=https://production.example.com
   
   # Security Scanning
   SNYK_TOKEN=your-snyk-token
   SONAR_TOKEN=your-sonar-token
   
   # Notifications (Optional)
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
   ```

## 🛠️ Setup Instructions

### 1. Environment Configuration

Copy and configure environment files:

```bash
# For staging
cp .env.staging.template .env.staging
# Edit .env.staging with your staging values

# For production
cp .env.prod.template .env.prod
# Edit .env.prod with your production values
```

### 2. Make Scripts Executable

```bash
chmod +x scripts/deploy.sh
chmod +x scripts/docker-health-check.sh
```

### 3. Local Development Setup

```bash
# Start all services for development
docker-compose up -d

# Check service health
./scripts/docker-health-check.sh development

# View logs
docker-compose logs -f [service-name]
```

## 🚀 Deployment Workflows

### Automatic Deployments

The CI/CD pipeline automatically handles deployments based on branch:

- **Feature Branches**: Runs tests and builds images (no deployment)
- **`develop` Branch**: Deploys to staging environment
- **`main` Branch**: Deploys to production environment

### Manual Deployment

Use the deployment script for manual deployments:

```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy specific version to production
./scripts/deploy.sh production v1.2.3

# Deploy latest to production
./scripts/deploy.sh production latest
```

### Health Monitoring

Monitor your deployed services:

```bash
# Check all services health
./scripts/docker-health-check.sh production

# Check specific environment
./scripts/docker-health-check.sh staging

# Check development environment
./scripts/docker-health-check.sh development
```

## 📊 Monitoring Access

### Production Environment
- **Application**: https://your-domain.com
- **API Gateway**: https://your-domain.com/api
- **Grafana Dashboard**: https://your-domain.com:3004
- **Prometheus**: https://your-domain.com:9090
- **RabbitMQ Management**: https://your-domain.com:15672

### Staging Environment
- **Application**: http://staging.your-domain.com:3003
- **RabbitMQ Management**: http://staging.your-domain.com:15672

### Local Development
- **API Gateway**: http://localhost:3003
- **Auth Service**: http://localhost:3000
- **Product Service**: http://localhost:3001
- **Order Service**: http://localhost:3002
- **MongoDB**: localhost:27017
- **RabbitMQ Management**: http://localhost:15672

## 🔧 Troubleshooting

### Common Issues

1. **Service Not Starting**
   ```bash
   # Check service logs
   docker-compose logs [service-name]
   
   # Check service health
   docker-compose ps
   
   # Restart specific service
   docker-compose restart [service-name]
   ```

2. **Database Connection Issues**
   ```bash
   # Check MongoDB status
   docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"
   
   # Check connection string in logs
   docker-compose logs auth | grep -i mongo
   ```

3. **RabbitMQ Connection Issues**
   ```bash
   # Check RabbitMQ status
   docker-compose exec rabbitmq rabbitmq-diagnostics ping
   
   # Access management UI
   # http://localhost:15672 (guest/guest)
   ```

4. **Memory/Performance Issues**
   ```bash
   # Check resource usage
   docker stats
   
   # Run comprehensive health check
   ./scripts/docker-health-check.sh
   ```

### Deployment Issues

1. **Failed Deployment**
   - Check GitHub Actions logs for detailed error messages
   - Verify all required secrets are set in GitHub repository
   - Ensure server has sufficient resources and Docker access

2. **Rollback Deployment**
   ```bash
   # Manual rollback (if automatic rollback failed)
   docker-compose down
   docker-compose -f docker-compose.backup.yml up -d
   ```

3. **Image Pull Issues**
   ```bash
   # Login to Docker Hub
   docker login
   
   # Pull images manually
   docker-compose pull
   ```

## 🔒 Security Considerations

1. **Environment Variables**: Never commit `.env.*` files to version control
2. **Secrets Management**: Use GitHub Secrets or external secret management
3. **Image Scanning**: Trivy scans are run automatically in CI/CD
4. **Access Control**: Limit SSH access and use key-based authentication
5. **Network Security**: Configure firewall rules for production deployments

## 📈 Performance Optimization

1. **Resource Limits**: Configured in production Docker Compose
2. **Image Optimization**: Multi-stage Dockerfiles for smaller images
3. **Caching**: GitHub Actions cache and Docker BuildKit caching
4. **Health Checks**: Proper health checks prevent traffic to unhealthy services

## 🔄 Maintenance

### Regular Tasks

1. **Update Dependencies**
   ```bash
   # Update Docker images
   docker-compose pull
   docker-compose up -d
   
   # Clean up old images
   docker image prune -f
   ```

2. **Monitor Logs**
   ```bash
   # Check for errors across all services
   docker-compose logs | grep -i error
   
   # Monitor specific service
   docker-compose logs -f --tail=100 [service-name]
   ```

3. **Backup Data**
   ```bash
   # Backup MongoDB data
   docker-compose exec mongodb mongodump --out /backup
   
   # Copy backup from container
   docker cp mongodb_container:/backup ./mongodb-backup
   ```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review GitHub Actions logs for CI/CD issues
3. Use the health check script for service diagnostics
4. Check service logs for application-specific issues

## 🤝 Contributing

When contributing to this project:
1. Make changes in feature branches
2. Ensure all tests pass locally
3. Update documentation for any new features
4. Follow the established coding standards
5. Test deployments in staging before production