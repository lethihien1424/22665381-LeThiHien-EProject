# Multi-stage build cho Auth Service
FROM node:18-alpine AS base

# Cài đặt dumb-init để xử lý signal tốt hơn
RUN apk add --no-cache dumb-init

# Tạo user non-root cho security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001

# Stage development - cho local development
FROM base AS development
WORKDIR /app
# Copy package files
COPY package*.json ./
# Install all dependencies (including dev dependencies)
RUN npm ci --only=development
# Copy source code
COPY . .
# Change ownership to non-root user
RUN chown -R nodeuser:nodejs /app
USER nodeuser
# Expose port
EXPOSE 3000
# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1
# Command để chạy ở development mode
CMD ["dumb-init", "node", "index.js"]

# Stage production - cho production deployment
FROM base AS production
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Remove unnecessary files
RUN rm -rf src/test node_modules/.cache

# Change ownership to non-root user
RUN chown -R nodeuser:nodejs /app
USER nodeuser

# Expose port (sử dụng port từ ENV hoặc default 3000)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Labels for metadata
LABEL org.opencontainers.image.title="EProject Auth Service"
LABEL org.opencontainers.image.description="Authentication microservice for EProject"
LABEL org.opencontainers.image.source="https://github.com/your-repo/eproject"

# Command
CMD ["dumb-init", "node", "index.js"]

# Default target for docker build
FROM production AS final
