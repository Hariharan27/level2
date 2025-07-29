# Project Management System - Project Structure

## Overview

This document outlines the complete project structure for the microservices-based Project Management System.

## Root Structure

```
level2/
├── prompt-library.md                       # AI Prompt Collection
└── project-management-system/              # Main Application
    ├── backend/                            # Backend Services
    │   ├── services/                       # 9 Microservices
    │   │   ├── auth-service/              # Authentication service
    │   │   ├── user-service/              # User management service
    │   │   ├── project-service/           # Project management service
    │   │   ├── task-service/              # Task management service
    │   │   ├── time-service/              # Time tracking service
    │   │   ├── file-service/              # File management service
    │   │   ├── comment-service/           # Comment service
    │   │   ├── notification-service/      # Notification service
    │   │   └── analytics-service/         # Analytics service
    │   ├── templates/                      # Service Templates
    │   ├── tests/                          # Integration Tests
    │   └── README.md                       # Backend Documentation
    ├── frontend/                           # Frontend Application
    │   ├── src/                            # React Source Code
    │   ├── public/                         # Static Assets
    │   ├── Dockerfile                      # Production Dockerfile
    │   ├── Dockerfile.dev                  # Development Dockerfile
    │   ├── .dockerignore                   # Docker Ignore File
    │   ├── nginx.conf                      # Nginx Configuration
    │   ├── package.json                    # Dependencies
    │   └── README.md                       # Frontend Documentation
    ├── infrastructure/                     # Infrastructure & DevOps
    │   ├── config/                         # Configuration Files
    │   │   ├── kong/                       # API Gateway Config
    │   │   ├── grafana/                    # Grafana Config
    │   │   ├── nginx/                      # Nginx Config
    │   │   └── prometheus.yml              # Prometheus Config
    │   ├── scripts/                        # Utility Scripts
    │   │   └── validate-environment.sh     # Environment Validation
    │   ├── deployment/                     # Deployment Configurations
    │   │   ├── docker/                     # Docker Deployment
    │   │   ├── kubernetes/                 # Kubernetes Manifests
    │   │   └── terraform/                  # Infrastructure as Code
    │   └── README.md                       # Infrastructure Documentation
    ├── docs/                               # Project Documentation
    │   ├── architecture/                   # Architecture & Design Docs
    │   │   ├── microservices-project-architecture.md
    │   │   ├── postgresql-microservices-schema.md
    │   │   ├── architecture-options-comparison.md
    │   │   └── project-management-architecture.md
    │   ├── api/                            # API Documentation
    │   │   └── microservices-api-design.md
    │   ├── development/                    # Development Guides
    │   │   ├── BACKEND_IMPLEMENTATION_PLAN.md
    │   │   └── FRONTEND_IMPLEMENTATION_PLAN.md
    │   └── deployment/                     # Deployment Guides
    ├── docker-compose.yml                  # Main Orchestration
    ├── .env.example                        # Environment Variables
    ├── README.md                           # Project Documentation
    ├── STARTUP_INSTRUCTIONS.md             # Setup Guide
    └── PROJECT_STRUCTURE.md                # This File
```

## Microservices Structure

### Service Template Structure
```
services/service-name/
├── src/
│   ├── apps/
│   │   └── app_name/
│   │       ├── models.py
│   │       ├── views.py
│   │       ├── serializers.py
│   │       ├── urls.py
│   │       └── tests.py
│   ├── core/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   └── manage.py
├── tests/
├── requirements.txt
├── Dockerfile
├── .env.example
└── README.md
```

### Individual Services
1. **auth-service/** - Authentication & Authorization
2. **user-service/** - User Management
3. **project-service/** - Project Management
4. **task-service/** - Task Management
5. **time-service/** - Time Tracking
6. **file-service/** - File Management
7. **comment-service/** - Comments & Discussions
8. **notification-service/** - Notifications
9. **analytics-service/** - Analytics & Reporting

## Frontend Structure

```
frontend/
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── components/
│   │   ├── auth/
│   │   ├── projects/
│   │   ├── tasks/
│   │   ├── time/
│   │   ├── analytics/
│   │   └── common/
│   ├── pages/
│   ├── services/
│   ├── utils/
│   ├── App.js
│   └── index.js
├── package.json
├── Dockerfile
└── nginx.conf
```

## Configuration Structure

```
config/
├── kong/
│   └── kong.yml                           # API Gateway Configuration
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── prometheus.yml
├── nginx/                                 # Nginx Configuration
└── prometheus.yml                         # Prometheus Configuration
```

## Infrastructure Services

### Database Services
- **auth-db** - PostgreSQL for Authentication
- **user-db** - PostgreSQL for User Management
- **project-db** - PostgreSQL for Projects
- **task-db** - PostgreSQL for Tasks
- **time-db** - PostgreSQL for Time Tracking
- **file-db** - PostgreSQL for File Metadata
- **comment-db** - PostgreSQL for Comments
- **analytics-db** - TimescaleDB for Analytics

### Infrastructure Services
- **redis** - Caching & Session Store
- **rabbitmq** - Message Queue
- **elasticsearch** - Search & Logging
- **prometheus** - Metrics Collection
- **grafana** - Monitoring Dashboard
- **minio** - File Storage (S3-compatible)

## Port Assignments

| Service | External Port | Internal Port | Description |
|---------|---------------|---------------|-------------|
| Frontend | 3000 | 3000 | React SPA |
| API Gateway | 8000 | 8000 | Kong Gateway |
| Kong Admin | 8443 | 8443 | Kong Administration |
| Auth Service | 8001 | 8000 | Authentication |
| User Service | 8002 | 8000 | User Management |
| Project Service | 8003 | 8000 | Project Management |
| Task Service | 8004 | 8000 | Task Management |
| Time Service | 8005 | 8000 | Time Tracking |
| File Service | 8006 | 8000 | File Management |
| Comment Service | 8007 | 8000 | Comments |
| Notification Service | 8008 | 8000 | Notifications |
| Analytics Service | 8009 | 8000 | Analytics |

## Environment Files

- **.env.example** - Main environment template
- **services/*/.env.example** - Service-specific environment templates

## Key Files

### Documentation
- **README.md** - Project overview and quick start
- **STARTUP_INSTRUCTIONS.md** - Detailed setup guide
- **PROJECT_STRUCTURE.md** - This file

### Configuration
- **docker-compose.yml** - Service orchestration
- **config/kong/kong.yml** - API Gateway routes
- **config/prometheus.yml** - Monitoring configuration

### Scripts
- **scripts/validate-environment.sh** - Environment validation

## Development Workflow

1. **Setup**: Copy .env.example to .env and configure
2. **Start**: `docker-compose up -d`
3. **Migrations**: Run migrations for each service
4. **Development**: Work on individual services
5. **Testing**: Use integration tests
6. **Deployment**: Use deployment configurations

## Architecture Principles

- **Service Autonomy**: Each service owns its data
- **API-First**: All communication via REST APIs
- **Containerization**: Docker for all services
- **Observability**: Comprehensive monitoring
- **Security**: JWT authentication, rate limiting
- **Scalability**: Horizontal scaling support 