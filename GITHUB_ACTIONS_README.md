# GitHub Actions CI/CD Pipeline

## Tổng quan
Dự án này sử dụng GitHub Actions để thực hiện CI/CD tự động cho hệ thống microservices bao gồm:
- Auth Service
- Product Service
- Order Service
- API Gateway

## Cấu trúc Workflows

### 1. CI/CD Pipeline (`ci-cd.yml`)
**Trigger**: Push vào `main`, `develop` hoặc Pull Request vào `main`

**Jobs**:
- **Test**: Chạy test cho tất cả services
- **Build**: Build và push Docker images lên Docker Hub
- **Deploy Staging**: Deploy lên môi trường staging (branch `develop`)
- **Deploy Production**: Deploy lên môi trường production (branch `main`)

### 2. Security & Quality Checks (`security-quality.yml`)
**Trigger**: Push, Pull Request, hoặc schedule hàng tuần

**Jobs**:
- **Security Scan**: Kiểm tra vulnerabilities với npm audit và Snyk
- **Code Quality**: Phân tích code quality với SonarCloud
- **Docker Security**: Scan Docker images với Trivy

### 3. Release & Deployment (`release.yml`)
**Trigger**: Push vào `main` hoặc tag version

**Jobs**:
- **Release**: Tự động tạo GitHub release với semantic versioning
- **Build Release**: Build Docker images với version tags
- **Deploy Production**: Deploy version mới lên production

## Cấu hình GitHub Secrets

### Docker Hub
```
DOCKER_USERNAME: your-dockerhub-username
DOCKER_PASSWORD: your-dockerhub-password
```

### Server SSH
```
STAGING_HOST: staging-server-ip
STAGING_USER: ssh-username
STAGING_SSH_KEY: private-ssh-key

PRODUCTION_HOST: production-server-ip
PRODUCTION_USER: ssh-username
PRODUCTION_SSH_KEY: private-ssh-key
PRODUCTION_URL: https://your-production-domain.com
```

### Security & Quality Tools
```
SNYK_TOKEN: your-snyk-api-token
SONAR_TOKEN: your-sonarcloud-token
GITHUB_TOKEN: your-github-token (tự động có sẵn)
PERSONAL_ACCESS_TOKEN: your-personal-access-token
```

### Notifications
```
SLACK_WEBHOOK_URL: your-slack-webhook-url
```

## Cách sử dụng

### 1. Development Workflow
```bash
# Tạo feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push và tạo Pull Request
git push origin feature/new-feature
```

### 2. Staging Deploy
```bash
# Merge vào develop branch
git checkout develop
git merge feature/new-feature
git push origin develop
# → Tự động deploy lên staging
```

### 3. Production Deploy
```bash
# Merge vào main branch
git checkout main
git merge develop
git push origin main
# → Tự động test, build, release và deploy lên production
```

## Environment Variables

### Staging (.env.staging)
```env
NODE_ENV=staging
JWT_SECRET=your-jwt-secret-staging
MONGO_URI_STAGING=mongodb://username:password@staging-mongo:27017/eproject
RABBITMQ_URL_STAGING=amqp://user:pass@staging-rabbitmq:5672
```

### Production (.env.production)
```env
NODE_ENV=production
JWT_SECRET=your-jwt-secret-production
MONGO_URI=mongodb://username:password@production-mongo:27017/eproject
RABBITMQ_URL=amqp://user:pass@production-rabbitmq:5672
```

## Monitoring và Logs

### Health Checks
Tất cả services đều có endpoint `/health` để kiểm tra trạng thái:
```bash
curl http://localhost:3000/health
```

### Docker Logs
```bash
# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của service cụ thể
docker-compose logs -f auth-service
```

### GitHub Actions Logs
- Vào tab "Actions" trong GitHub repository
- Click vào workflow run để xem chi tiết logs

## Troubleshooting

### Build Failures
1. Kiểm tra Dockerfile của service bị lỗi
2. Đảm bảo dependencies được cài đặt đúng
3. Kiểm tra environment variables

### Deployment Failures
1. Kiểm tra SSH connection đến server
2. Verify Docker images đã được push thành công
3. Kiểm tra server resources (disk space, memory)

### Test Failures
1. Chạy tests locally trước khi push
2. Kiểm tra test environment setup
3. Verify database connections trong tests

## Best Practices

### Commit Messages
Sử dụng conventional commits:
```
feat: add new feature
fix: bug fix
docs: update documentation
style: formatting changes
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

### Branch Strategy
- `main`: Production code
- `develop`: Staging/integration branch
- `feature/*`: Feature development
- `hotfix/*`: Production fixes

### Docker Images
- Sử dụng multi-stage builds để giảm size
- Tag images với version numbers
- Thường xuyên cleanup unused images

## Rollback Strategy

### Nhanh chóng rollback
```bash
# SSH vào production server
ssh user@production-server

# Rollback bằng backup images
docker-compose down
docker tag eproject-auth:backup eproject-auth:latest
docker tag eproject-product:backup eproject-product:latest
docker tag eproject-order:backup eproject-order:latest
docker tag eproject-api-gateway:backup eproject-api-gateway:latest
docker-compose up -d
```

### Rollback với version cụ thể
```bash
# Set version cần rollback
export VERSION=v1.2.3
docker-compose down
docker-compose up -d
```