---
name: docker-patterns
description: Docker Compose patterns for local development environments. Use when setting up containerized dev environments with PostgreSQL, Redis, or multi-service architectures.
---

# Docker Patterns for Local Development

## FastAPI + PostgreSQL + Redis

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    volumes:
      - .:/app
      - /app/.venv  # Exclude venv from mount
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    command: uvicorn main:app --host 0.0.0.0 --reload

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## Development Dockerfile

```dockerfile
# Dockerfile.dev
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY pyproject.toml .
RUN pip install -e ".[dev]"

# Copy application code
COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--reload"]
```

## Node.js + MongoDB + Redis

```yaml
services:
  app:
    build:
      context: .
      target: development
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules  # Exclude node_modules
    environment:
      - NODE_ENV=development
      - MONGODB_URI=mongodb://mongo:27017/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - mongo
      - redis
    command: npm run dev

  mongo:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  mongo_data:
```

## Multi-Stage Node Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine AS base
WORKDIR /app

FROM base AS development
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

FROM base AS builder
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM base AS production
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

## Environment Variables Pattern

```yaml
# docker-compose.yml
services:
  app:
    env_file:
      - .env.docker  # Docker-specific overrides
    environment:
      # Override specific vars
      - DEBUG=true
```

```bash
# .env.docker
DATABASE_URL=postgresql://postgres:postgres@db:5432/app
REDIS_URL=redis://redis:6379/0
SECRET_KEY=dev-secret-key-not-for-production
```

## Health Check Patterns

```yaml
services:
  api:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5
```

## Development Overrides

```yaml
# docker-compose.override.yml (auto-loaded in dev)
services:
  app:
    volumes:
      - .:/app
    environment:
      - DEBUG=true
    ports:
      - "8000:8000"
      - "5678:5678"  # Debugger port
```

## Useful Commands

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f app

# Rebuild after dependency changes
docker compose up -d --build

# Shell into container
docker compose exec app bash

# Run one-off command
docker compose run --rm app pytest

# Clean up
docker compose down -v  # -v removes volumes
```

## .dockerignore

```
.git
.gitignore
.env
.env.*
!.env.docker
__pycache__
*.pyc
.pytest_cache
.mypy_cache
.ruff_cache
node_modules
dist
build
*.log
.venv
venv
.coverage
htmlcov
```
