# Project Management System - Microservices Architecture

## Overview

This is a production-ready microservices-based project management system built with Django REST Framework, React, and PostgreSQL. The system is designed for scalability, maintainability, and real-time collaboration.

## Architecture

The system follows a microservices architecture with clear separation of concerns:

### Backend Services (9 Microservices)
1. **Authentication Service** - User authentication, JWT tokens, OAuth
2. **User Service** - User profiles, organizations, teams
3. **Project Service** - Project management, milestones
4. **Task Service** - Task management, assignments, dependencies
5. **Time Tracking Service** - Time entries, timesheets
6. **File Service** - File uploads, storage, sharing
7. **Comment Service** - Comments, reactions, discussions
8. **Notification Service** - Notifications, real-time updates
9. **Analytics Service** - Analytics, reporting, metrics

### Frontend Application
- **React SPA** - Modern user interface with TypeScript

### Infrastructure
- **API Gateway** - Kong for routing and load balancing
- **Monitoring** - Prometheus and Grafana
- **Caching** - Redis for session and data caching
- **Message Queue** - RabbitMQ for asynchronous processing

## Tech Stack

- **Backend**: Python, Django, Django REST Framework
- **Frontend**: React.js (SPA)
- **Database**: PostgreSQL (multiple instances)
- **Cache**: Redis
- **Message Queue**: RabbitMQ
- **API Gateway**: Kong
- **Storage**: S3/MinIO
- **Monitoring**: Prometheus, Grafana
- **Containerization**: Docker, Docker Compose

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for frontend development)
- Python 3.11+ (for backend development)

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project-management-system
   ```

2. **Copy environment files**
   ```bash
   cp .env.example .env
   cp backend/services/*/.env.example backend/services/*/.env
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**
   ```bash
   docker-compose exec auth-service python manage.py migrate
   docker-compose exec user-service python manage.py migrate
   docker-compose exec project-service python manage.py migrate
   docker-compose exec task-service python manage.py migrate
   docker-compose exec time-service python manage.py migrate
   ```

5. **Create superuser**
   ```bash
   docker-compose exec auth-service python manage.py createsuperuser
   ```

6. **Access the application**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8000
   - Kong Admin: http://localhost:8443

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | React SPA |
| API Gateway | http://localhost:8000 | Kong Gateway |
| Kong Admin | http://localhost:8443 | Kong Administration |
| Auth Service | http://localhost:8001 | Authentication |
| User Service | http://localhost:8002 | User Management |
| Project Service | http://localhost:8003 | Project Management |
| Task Service | http://localhost:8004 | Task Management |
| Time Service | http://localhost:8005 | Time Tracking |
| File Service | http://localhost:8006 | File Management |
| Comment Service | http://localhost:8007 | Comments |
| Notification Service | http://localhost:8008 | Notifications |
| Analytics Service | http://localhost:8009 | Analytics |

## Development

### Service Structure

Each service follows this structure:
```
services/{service-name}/
├── src/
│   ├── apps/
│   ├── core/
│   ├── api/
│   └── manage.py
├── tests/
├── config/
├── requirements.txt
├── Dockerfile
├── .env.example
└── README.md
```

### Adding a New Service

1. Create service directory in `services/`
2. Copy template from `templates/service-template/`
3. Update service-specific configurations
4. Add to `docker-compose.yml`
5. Update API Gateway configuration

### Database Migrations

Each service manages its own database migrations:

```bash
# Generate migration
docker-compose exec {service-name} python manage.py makemigrations

# Apply migration
docker-compose exec {service-name} python manage.py migrate
```

### Testing

```bash
# Run tests for specific service
docker-compose exec {service-name} python manage.py test

# Run all tests
docker-compose exec test-runner python -m pytest
```

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **API Specs**: `/docs/api-specs/`

## Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
- **Kibana**: http://localhost:5601

## Production Deployment

See `deployment/` directory for production deployment configurations:

- Kubernetes manifests
- Helm charts
- CI/CD pipelines
- Monitoring setup

## Contributing

1. Follow the microservices architecture patterns
2. Maintain service boundaries
3. Write tests for new features
4. Update API documentation
5. Follow the coding standards

## License

MIT License - see LICENSE file for details. 