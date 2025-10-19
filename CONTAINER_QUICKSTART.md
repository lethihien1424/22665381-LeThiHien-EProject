# 🚀 EProject Container - Hướng dẫn bắt đầu nhanh

## ✅ Container hóa hoàn chỉnh - Sẵn sàng sử dụng!

Dự án của bạn đã được container hóa hoàn toàn với tất cả các tính năng cần thiết để chạy độc lập, không bị xung đột với môi trường gốc.

## 🎯 Bắt đầu ngay (3 bước đơn giản)

### Bước 1: Chạy script tự động
```bash
# Làm cho script có thể thực thi
chmod +x scripts/setup-containers.sh

# Chạy script tự động thiết lập
./scripts/setup-containers.sh
```

### Bước 2: Hoặc chạy thủ công
```bash
# Tạo file môi trường
cp .env.staging.template .env

# Khởi động tất cả services
docker-compose up -d

# Kiểm tra trạng thái
docker-compose ps
```

### Bước 3: Kiểm tra kết quả
```bash
# Kiểm tra health
./scripts/docker-health-check.sh

# Xem logs
docker-compose logs -f api-gateway
```

## 🌐 Truy cập các services

- **API Gateway**: http://localhost:3003
- **Auth Service**: http://localhost:3000
- **Product Service**: http://localhost:3001
- **Order Service**: http://localhost:3002
- **MongoDB**: localhost:27017
- **RabbitMQ**: http://localhost:15672 (guest/guest)

## 🔧 Tính năng Container đã được tối ưu

### ✅ Multi-stage Dockerfiles
- Development stage cho local development
- Production stage cho deployment
- Security tối ưu với non-root user
- Health checks tự động

### ✅ Tương thích hoàn toàn
- Không thay đổi code gốc
- Ports chính xác theo dự án
- Environment variables được map đúng
- Cấu trúc thư mục giữ nguyên

### ✅ Container Structure Tests
- Validate container structure tự động
- Kiểm tra file và thư mục cần thiết
- Test command execution
- Verify ports và metadata

### ✅ Optimization
- .dockerignore để tối ưu build time
- Layer caching tối đa
- Security best practices
- Resource management

## 🚨 Các lệnh quan trọng

```bash
# Khởi động tất cả
docker-compose up -d

# Dừng tất cả
docker-compose down

# Xem logs realtime
docker-compose logs -f [service-name]

# Restart một service
docker-compose restart auth

# Rebuild và restart
docker-compose up -d --build auth

# Kiểm tra resource usage
docker stats

# Dọn dẹp hoàn toàn
docker-compose down -v
docker system prune -f
```

## 🔍 Troubleshooting

### Nếu service không start:
```bash
# Xem logs chi tiết
docker-compose logs auth

# Kiểm tra container
docker-compose ps

# Restart service
docker-compose restart auth
```

### Nếu port bị conflict:
```bash
# Kiểm tra port đang sử dụng
netstat -tulpn | grep :3000

# Hoặc thay đổi port trong docker-compose.yml
```

### Nếu cần reset hoàn toàn:
```bash
# Dừng và xóa tất cả
docker-compose down -v
docker system prune -af

# Chạy lại setup
./scripts/setup-containers.sh
```

## 📊 Monitoring & Health Check

```bash
# Script kiểm tra health tự động
./scripts/docker-health-check.sh

# Kiểm tra resource usage
docker stats --no-stream

# Xem network containers
docker network ls
docker network inspect eproject-phase-1_default
```

## 🎉 Hoàn tất!

Dự án của bạn bây giờ đã:
- ✅ Hoàn toàn containerized
- ✅ Tương thích với dự án gốc  
- ✅ Sẵn sàng cho CI/CD
- ✅ Có monitoring và health checks
- ✅ Optimized cho performance
- ✅ Security best practices

**Bạn có thể bắt đầu phát triển ngay mà không lo lắng về conflicts!**