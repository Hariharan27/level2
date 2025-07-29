# Backend - Project Management System

## Overview

This is the backend for the Project Management System, built with Django microservices architecture. The system consists of 9 independent microservices, each with its own database and API endpoints.

## Architecture

### Microservices

1. **Authentication Service** (`auth-service`)
   - User authentication and authorization
   - JWT token management
   - OAuth integration

2. **User Service** (`user-service`)
   - User profile management
   - Organization and team management
   - User preferences

3. **Project Service** (`project-service`)
   - Project CRUD operations
   - Project settings and configuration
   - Project templates

4. **Task Service** (`task-service`)
   - Task management and assignments
   - Task dependencies and workflows
   - Task status tracking

5. **Time Tracking Service** (`time-service`)
   - Time entry management
   - Timesheet generation
   - Time analytics

6. **File Service** (`file-service`)
   - File upload and storage
   - File sharing and permissions
   - File versioning

7. **Comment Service** (`comment-service`)
   - Comments and discussions
   - Reactions and notifications
   - Thread management

8. **Notification Service** (`notification-service`)
   - Real-time notifications
   - Email notifications
   - Push notifications

9. **Analytics Service** (`analytics-service`)
   - Data analytics and reporting
   - Performance metrics
   - Business intelligence

## Tech Stack

- **Framework**: Django + Django REST Framework
- **Database**: PostgreSQL (multiple instances)
- **Cache**: Redis
- **Message Queue**: RabbitMQ
- **Authentication**: JWT (djangorestframework-simplejwt)
- **Containerization**: Docker
- **API Gateway**: Kong
- **Monitoring**: Prometheus + Grafana

## Project Structure

```
backend/
├── services/                    # Microservices
│   ├── auth-service/           # Authentication service
│   ├── user-service/           # User management service
│   ├── project-service/        # Project management service
│   ├── task-service/           # Task management service
│   ├── time-service/           # Time tracking service
│   ├── file-service/           # File management service
│   ├── comment-service/        # Comment service
│   ├── notification-service/   # Notification service
│   └── analytics-service/      # Analytics service
├── templates/                   # Service templates
│   └── service-template/       # Template for new services
├── tests/                      # Integration tests
└── README.md                   # This file
```

## Service Structure

Each service follows this structure:

```
service-name/
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

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Python 3.11+
- PostgreSQL
- Redis

### Environment Setup

1. **Copy environment files:**
   ```bash
   # From project root
   cp .env.example .env
   
   # Copy service-specific environment files
   cp backend/services/*/.env.example backend/services/*/.env
   ```

2. **Configure environment variables:**
   ```bash
   # Database password
   DB_PASSWORD=your_secure_db_password_here
   
   # JWT secret
   JWT_SECRET=your_super_secret_jwt_key_here
   
   # Email configuration
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_HOST_USER=your_email@gmail.com
   EMAIL_HOST_PASSWORD=your_email_app_password
   ```

### Running Services

#### All Services (Production)
```bash
# From project root
docker-compose up -d
```

#### Individual Service (Development)
```bash
# Navigate to service directory
cd backend/services/auth-service

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start development server
python manage.py runserver 0.0.0.0:8000
```

#### Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Auth Service | http://localhost:8001 | Authentication |
| User Service | http://localhost:8002 | User Management |
| Project Service | http://localhost:8003 | Project Management |
| Task Service | http://localhost:8004 | Task Management |
| Time Service | http://localhost:8005 | Time Tracking |
| File Service | http://localhost:8006 | File Management |
| Comment Service | http://localhost:8007 | Comments |
| Notification Service | http://localhost:8008 | Notifications |
| Analytics Service | http://localhost:8009 | Analytics |

## API Documentation

### Authentication

All services use JWT authentication:

```bash
# Login
POST /api/v1/auth/login/
{
    "username": "user@example.com",
    "password": "password"
}

# Response
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Common Headers

```bash
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Error Handling

All services return standardized error responses:

```json
{
    "error": "error_code",
    "message": "Human readable error message",
    "details": {}
}
```

## Database Schema

Each service has its own PostgreSQL database:

- **auth_db** - Authentication data
- **user_db** - User profiles and organizations
- **project_db** - Projects and settings
- **task_db** - Tasks and assignments
- **time_db** - Time entries and timesheets
- **file_db** - File metadata
- **comment_db** - Comments and discussions
- **analytics_db** - Analytics data (TimescaleDB)

## Testing

### Running Tests

```bash
# All services
docker-compose exec auth-service python manage.py test
docker-compose exec user-service python manage.py test
# ... repeat for all services

# Individual service
cd backend/services/auth-service
python manage.py test
```

### Test Structure

```
tests/
├── unit/              # Unit tests
├── integration/       # Integration tests
├── api/              # API tests
└── fixtures/         # Test data
```

## Monitoring

### Health Checks

Each service provides a health check endpoint:

```bash
GET /health
```

Response:
```json
{
    "status": "healthy",
    "service": "auth-service",
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
}
```

### Metrics

Services expose Prometheus metrics at `/metrics`:

```bash
GET /metrics
```

### Logging

Structured logging with JSON format:

```json
{
    "timestamp": "2024-01-01T00:00:00Z",
    "level": "INFO",
    "service": "auth-service",
    "message": "User login successful",
    "user_id": "123",
    "ip": "192.168.1.1"
}
```

## Security

### Authentication

- JWT tokens with configurable expiration
- Refresh token rotation
- Token blacklisting

### Authorization

- Role-based access control (RBAC)
- Permission-based authorization
- Service-to-service authentication

### Data Protection

- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CSRF protection

## Performance

### Caching

- Redis for session storage
- Redis for API response caching
- Database query caching

### Database Optimization

- Connection pooling
- Query optimization
- Indexing strategy
- Read replicas for analytics

### API Optimization

- Pagination for large datasets
- Filtering and sorting
- Response compression
- Rate limiting

## Deployment

### Docker

Each service is containerized with Docker:

```bash
# Build service
docker build -t auth-service ./backend/services/auth-service

# Run service
docker run -p 8001:8000 auth-service
```

### Environment Variables

Required environment variables for each service:

```bash
# Database
DATABASE_URL=postgresql://postgres:password@service-db:5432/service_db

# Redis
REDIS_URL=redis://redis:6379

# Django
DEBUG=False
SECRET_KEY=your_service_secret_key
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Service Communication
AUTH_SERVICE_URL=http://auth-service:8000
USER_SERVICE_URL=http://user-service:8000
# ... other service URLs
```

## Troubleshooting

### Common Issues

1. **Database connection failed:**
   ```bash
   # Check database status
   docker-compose ps
   
   # Check database logs
   docker-compose logs auth-db
   ```

2. **Service not starting:**
   ```bash
   # Check service logs
   docker-compose logs auth-service
   
   # Check environment variables
   docker-compose exec auth-service env
   ```

3. **Migration issues:**
   ```bash
   # Reset migrations
   docker-compose exec auth-service python manage.py migrate --fake-initial
   ```

### Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs auth-service

# Follow logs
docker-compose logs -f auth-service
```

## Contributing

1. Follow the established service structure
2. Add proper error handling
3. Include comprehensive tests
4. Update API documentation
5. Follow security best practices
6. Add monitoring and logging

## Best Practices

1. **Service Independence**: Each service should be autonomous
2. **API Design**: Follow RESTful principles
3. **Error Handling**: Use standardized error responses
4. **Security**: Implement proper authentication and authorization
5. **Testing**: Maintain high test coverage
6. **Documentation**: Keep API documentation updated
7. **Monitoring**: Implement comprehensive monitoring
8. **Performance**: Optimize for scalability 