# # Multi-stage build cho API Gateway Service
# FROM node:18-alpine AS base

# # Cài đặt dumb-init và curl cho health checks
# RUN apk add --no-cache dumb-init curl

# # Tạo user non-root cho security
# RUN addgroup -g 1001 -S nodejs
# RUN adduser -S nodeuser -u 1001

# # Stage development
# FROM base AS development
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci --include=dev
# COPY . .
# RUN chown -R nodeuser:nodejs /app
# USER nodeuser
# EXPOSE 3003
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:3003/health || exit 1
# CMD ["dumb-init", "node", "index.js"]

# # Stage production
# FROM base AS production
# WORKDIR /app

# # Copy package files và install production dependencies
# COPY package*.json ./
# RUN npm ci --only=production && npm cache clean --force

# # Copy source code
# COPY . .

# # Remove cache
# RUN rm -rf node_modules/.cache

# # Set permissions
# RUN chown -R nodeuser:nodejs /app
# USER nodeuser

# EXPOSE 3003

# # Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#     CMD curl -f http://localhost:3003/health || exit 1

# # Labels
# LABEL org.opencontainers.image.title="EProject API Gateway"
# LABEL org.opencontainers.image.description="API Gateway for EProject microservices"

# CMD ["dumb-init", "node", "index.js"]

# FROM production AS final
# Base image
FROM node:18-alpine AS base
RUN apk add --no-cache dumb-init curl
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001

# Production stage
FROM base AS production
WORKDIR /app

# Copy package files và install production dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Remove cache
RUN rm -rf node_modules/.cache

# Set permissions
RUN chown -R nodeuser:nodejs /app
USER nodeuser

EXPOSE 3003

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3003/health || exit 1

# Labels
LABEL org.opencontainers.image.title="EProject API Gateway"
LABEL org.opencontainers.image.description="API Gateway for EProject microservices"

# CMD start server
CMD ["dumb-init", "node", "index.js"]
