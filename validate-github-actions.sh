#!/bin/bash

# GitHub Actions Validation Script
# Kiểm tra setup GitHub Actions cho dự án microservices

echo "🔍 Kiểm tra GitHub Actions Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 - File không tồn tại${NC}"
        return 1
    fi
}

# Function to check directory
check_directory() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅ $1/${NC}"
        return 0
    else
        echo -e "${RED}❌ $1/ - Directory không tồn tại${NC}"
        return 1
    fi
}

echo "📁 Kiểm tra cấu trúc files và directories:"
echo "----------------------------------------"

# Check GitHub Actions directory and files
check_directory ".github"
check_directory ".github/workflows"
check_file ".github/workflows/ci-cd.yml"
check_file ".github/workflows/security-quality.yml" 
check_file ".github/workflows/release.yml"

# Check Docker files
echo -e "\n🐳 Kiểm tra Docker files:"
echo "------------------------"
check_file "Docker-compose.yml"
check_file "docker-compose.staging.yml"
check_file "auth/Dockerfile"
check_file "product/Dockerfile"
check_file "order/Dockerfile"
check_file "api-gateway/Dockerfile"

# Check package.json files
echo -e "\n📦 Kiểm tra package.json files:"
echo "-------------------------------"
check_file "auth/package.json"
check_file "product/package.json"
check_file "order/package.json"
check_file "api-gateway/package.json"

# Check configuration files
echo -e "\n⚙️ Kiểm tra configuration files:"
echo "--------------------------------"
check_file "sonar-project.properties"
check_file "GITHUB_ACTIONS_README.md"

# Validate YAML syntax
echo -e "\n🔧 Kiểm tra YAML syntax:"
echo "------------------------"
if command -v yamllint &> /dev/null; then
    yamllint .github/workflows/*.yml && echo -e "${GREEN}✅ YAML syntax hợp lệ${NC}" || echo -e "${RED}❌ YAML syntax có lỗi${NC}"
else
    echo -e "${YELLOW}⚠️ yamllint không được cài đặt, bỏ qua kiểm tra YAML syntax${NC}"
fi

# Check for required secrets (informational)
echo -e "\n🔐 GitHub Secrets cần thiết:"
echo "----------------------------"
echo "Docker Hub:"
echo "  - DOCKER_USERNAME"
echo "  - DOCKER_PASSWORD"
echo ""
echo "SSH Servers:"
echo "  - STAGING_HOST"
echo "  - STAGING_USER" 
echo "  - STAGING_SSH_KEY"
echo "  - PRODUCTION_HOST"
echo "  - PRODUCTION_USER"
echo "  - PRODUCTION_SSH_KEY"
echo "  - PRODUCTION_URL"
echo ""
echo "Security & Quality:"
echo "  - SNYK_TOKEN"
echo "  - SONAR_TOKEN"
echo "  - PERSONAL_ACCESS_TOKEN"
echo ""
echo "Notifications:"
echo "  - SLACK_WEBHOOK_URL"

# Check package.json scripts
echo -e "\n📝 Kiểm tra package.json scripts:"
echo "--------------------------------"
for service in auth product order api-gateway; do
    if [ -f "$service/package.json" ]; then
        echo "📋 $service service:"
        if grep -q '"test"' "$service/package.json"; then
            echo -e "  ${GREEN}✅ test script${NC}"
        else
            echo -e "  ${YELLOW}⚠️ test script không tìm thấy${NC}"
        fi
        
        if grep -q '"lint"' "$service/package.json"; then
            echo -e "  ${GREEN}✅ lint script${NC}"
        else
            echo -e "  ${YELLOW}⚠️ lint script không tìm thấy${NC}"
        fi
        
        if grep -q '"start"' "$service/package.json"; then
            echo -e "  ${GREEN}✅ start script${NC}"
        else
            echo -e "  ${RED}❌ start script không tìm thấy${NC}"
        fi
    fi
done

echo -e "\n🎯 Khuyến nghị setup:"
echo "--------------------"
echo "1. Cài đặt tất cả GitHub Secrets cần thiết"
echo "2. Tạo staging và production environments trên GitHub"
echo "3. Setup SonarCloud project"
echo "4. Cấu hình Snyk integration"
echo "5. Thêm test scripts vào package.json nếu chưa có"
echo "6. Kiểm tra Dockerfile có optimized không"
echo "7. Setup monitoring và logging"

echo -e "\n✅ Validation hoàn thành!"