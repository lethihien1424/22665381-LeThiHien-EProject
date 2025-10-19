# -------------------------------
# Stage 1: Base Image
# -------------------------------
FROM node:18-alpine AS base

# Cài các gói cần thiết
RUN apk add --no-cache dumb-init curl

# Tạo user không phải root để tăng bảo mật
RUN addgroup -S nodejs && adduser -S nodeuser -G nodejs

WORKDIR /app
COPY package*.json ./

# -------------------------------
# Stage 2: Development (optional)
# -------------------------------
FROM base AS development
RUN npm install
COPY . .
RUN chown -R nodeuser:nodejs /app
USER nodeuser

EXPOSE 3002

# Health check endpoint (bắt buộc có trong code)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3002/health || exit 1

CMD ["dumb-init", "node", "index.js"]

# -------------------------------
# Stage 3: Production
# -------------------------------
FROM base AS production

# Cài chỉ dependency cần thiết (nhanh + nhẹ)
RUN npm ci --only=production && npm cache clean --force

COPY . .
RUN rm -rf node_modules/.cache
RUN chown -R nodeuser:nodejs /app
USER nodeuser

EXPOSE 3002

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3002/health || exit 1

# Label metadata
LABEL org.opencontainers.image.title="EProject Order Service"
LABEL org.opencontainers.image.description="Order management microservice for EProject"
LABEL maintainer="Luong Tan <your-email@example.com>"

CMD ["dumb-init", "node", "index.js"]
