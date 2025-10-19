# 🎯 Hướng dẫn thực hiện CI/CD với GitHub Actions

## 📋 Tổng quan
Dự án EProject đã được thiết lập hoàn chỉnh với GitHub Actions CI/CD pipeline bao gồm:
- **ci-cd.yml**: Pipeline chính cho build, test và deploy
- **docker-enhanced-ci-cd.yml**: Pipeline nâng cao với Docker multi-platform
- **security-quality.yml**: Security scanning và code quality checks
- **release.yml**: Tự động tạo releases

## 🛠️ Thiết lập ban đầu

### Bước 1: Chuẩn bị GitHub Repository

```bash
# 1. Khởi tạo Git (đã hoàn thành)
git init

# 2. Thêm remote repository (thay YOUR_USERNAME và YOUR_REPO)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# 3. Tạo branch main và develop
git checkout -b main
git checkout -b develop
```

### Bước 2: Cấu hình GitHub Secrets

Truy cập GitHub → Settings → Secrets and variables → Actions và thêm:

#### 🐳 Docker Hub Secrets
```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-access-token
```

#### 🔐 Server Deployment Secrets
```
# Staging Server
STAGING_HOST=staging.yourdomain.com
STAGING_USER=deploy
STAGING_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
STAGING_URL=http://staging.yourdomain.com

# Production Server
PRODUCTION_HOST=yourdomain.com
PRODUCTION_USER=deploy
PRODUCTION_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
PRODUCTION_URL=https://yourdomain.com
```

#### 🔍 Security Scanning Secrets
```
SNYK_TOKEN=your-snyk-token
SONAR_TOKEN=your-sonarcloud-token
```

#### 📢 Notification Secrets (Optional)
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

## 🚀 Quy trình CI/CD

### Workflow Triggers

1. **Push to feature branches**: Chạy tests + build images
2. **Push to develop**: Deploy to staging
3. **Push to main**: Deploy to production
4. **Pull requests**: Chạy full test suite

### Pipeline Stages

```mermaid
graph LR
    A[Code Push] --> B[Detect Changes]
    B --> C[Run Tests]
    C --> D[Build Docker Images]
    D --> E[Security Scan]
    E --> F{Branch?}
    F -->|develop| G[Deploy Staging]
    F -->|main| H[Deploy Production]
    G --> I[Health Check]
    H --> I
```

## 📝 Hướng dẫn từng bước

### Bước 3: Test CI/CD Pipeline

1. **Commit và push code:**
```bash
# Add all files
git add .

# Commit với message rõ ràng
git commit -m "feat: setup complete CI/CD pipeline with Docker"

# Push lên GitHub
git push origin main
```

2. **Tạo feature branch để test:**
```bash
# Tạo feature branch
git checkout -b feature/test-cicd

# Thay đổi nhỏ (ví dụ: update README)
echo "# Testing CI/CD" >> TEST.md
git add TEST.md
git commit -m "feat: add test file for CI/CD"

# Push feature branch
git push origin feature/test-cicd
```

3. **Tạo Pull Request trên GitHub**
   - Truy cập GitHub repository
   - Tạo Pull Request từ `feature/test-cicd` → `main`
   - Xem CI/CD pipeline chạy tự động

### Bước 4: Kiểm tra Pipeline Results

Truy cập GitHub → Actions tab để xem:
- ✅ Test results
- 🐳 Docker image builds
- 🔍 Security scan results
- 📊 Code quality metrics

### Bước 5: Deploy to Staging

```bash
# Merge PR và switch to develop
git checkout develop
git merge feature/test-cicd

# Push to develop → triggers staging deployment
git push origin develop
```

### Bước 6: Deploy to Production

```bash
# Switch to main branch
git checkout main
git merge develop

# Push to main → triggers production deployment
git push origin main
```

## 🔧 Customization

### Thay đổi Docker Registry

Nếu không dùng Docker Hub, sửa trong workflows:
```yaml
env:
  REGISTRY: ghcr.io  # Hoặc registry khác
```

### Thêm Environment Variables

Trong GitHub Secrets, thêm:
```
DATABASE_URL=your-database-url
API_KEY=your-api-key
```

Và trong workflow:
```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}
```

### Custom Deployment Targets

Sửa file deployment trong workflows:
```yaml
deploy-custom:
  if: github.ref == 'refs/heads/custom-branch'
  environment: custom
```

## 📊 Monitoring & Debugging

### Xem Logs Pipeline

1. GitHub → Actions → Select workflow run
2. Click vào job để xem chi tiết
3. Expand steps để xem logs

### Debug Failed Deployments

```bash
# Kiểm tra trên server
ssh user@server
docker-compose logs [service-name]

# Rollback nếu cần
docker-compose down
docker-compose -f docker-compose.backup.yml up -d
```

### Health Check Commands

```bash
# Local health check
./scripts/docker-health-check.sh

# Remote health check
curl -f https://yourdomain.com/health
```

## 🎯 Best Practices

### 1. Branch Strategy
- `main`: Production code
- `develop`: Staging code  
- `feature/*`: Feature development
- `hotfix/*`: Emergency fixes

### 2. Commit Messages
```bash
feat: add new feature
fix: fix bug
docs: update documentation  
chore: maintenance tasks
test: add tests
```

### 3. Environment Management
- Development: Local Docker
- Staging: develop branch
- Production: main branch

### 4. Security
- Không commit secrets
- Sử dụng GitHub Secrets
- Regular security scans
- Review dependencies

## ⚡ Quick Commands

```bash
# Build local
docker-compose build

# Test local
docker-compose up -d
./scripts/docker-health-check.sh

# Manual deployment
./scripts/deploy.sh staging
./scripts/deploy.sh production

# View logs
docker-compose logs -f [service]

# Cleanup
docker-compose down -v
docker system prune -f
```

## 🚨 Troubleshooting

### Common Issues

1. **Docker build fails**
   - Kiểm tra Dockerfile syntax
   - Verify dependencies in package.json

2. **Deployment fails**
   - Kiểm tra SSH keys
   - Verify server access
   - Check disk space

3. **Tests fail**
   - Chạy tests local trước
   - Kiểm tra environment variables
   - Review test dependencies

### Getting Help

1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Test locally với `./scripts/docker-health-check.sh`
4. Check server logs với `docker-compose logs`

## 🎉 Success Metrics

CI/CD pipeline thành công khi:
- ✅ All tests pass
- ✅ Docker images build successfully  
- ✅ Security scans pass
- ✅ Deployments complete without errors
- ✅ Health checks return OK
- ✅ Application accessible via URLs

---

**🚀 Ready to go! Your CI/CD pipeline is now fully configured and ready for production use!**
GitHub Actions CI/CD giúp bạn tự động hóa toàn bộ quy trình kiểm thử, build, và triển khai dự án.
🔹 Mỗi lần commit, hệ thống tự:

kiểm tra code,

build Docker,

đẩy lên Docker Hub,

triển khai lên server staging/production.
🔹 Giúp bạn phát hiện lỗi sớm, triển khai nhanh, giảm rủi ro và tiết kiệm thời gian.