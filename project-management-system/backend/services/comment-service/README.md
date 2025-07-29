# Service Template

## Overview

This is a template for Django microservices in the Project Management System. Copy this template and customize it for your specific service.

## Features

- Django REST Framework API
- PostgreSQL database integration
- Redis caching
- JWT authentication
- Health check endpoint
- Docker containerization
- Comprehensive testing setup
- Code quality tools

## API Endpoints

### Health Check
- `GET /health` - Service health check

### Service-Specific Endpoints
- Add your service-specific endpoints here

## Database Schema

The service owns the following tables in its database:

- Add your service-specific tables here

## Environment Variables

```bash
# Database
DATABASE_URL=postgresql://postgres:password@service-db:5432/service_db

# Redis
REDIS_URL=redis://redis:6379

# Django Settings
DEBUG=True
SECRET_KEY=your_service_secret_key
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Service Communication
AUTH_SERVICE_URL=http://auth-service:8000
USER_SERVICE_URL=http://user-service:8000
# Add other service URLs as needed
```

## Setup

1. **Copy template to new service**
   ```bash
   cp -r templates/service-template/ services/your-service-name/
   ```

2. **Customize the service**
   - Update service name in all files
   - Modify environment variables
   - Add service-specific models and endpoints
   - Update README.md

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run migrations**
   ```bash
   python manage.py migrate
   ```

5. **Run the service**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

## Development

### Project Structure
```
your-service-name/
├── src/
│   ├── apps/
│   │   └── your_app/
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

### Running Tests
```bash
python manage.py test
```

### Code Quality
```bash
# Run linting
flake8 src/
black src/
isort src/
```

## Integration

### Service Communication

This service communicates with:
- List other services this service communicates with

### External Dependencies

- **PostgreSQL**: Data storage
- **Redis**: Caching and sessions
- Add other dependencies as needed

## Security

- JWT token validation
- Input validation and sanitization
- Rate limiting
- CORS configuration
- SQL injection prevention

## Monitoring

- Health check endpoint
- Request/response logging
- Error tracking
- Performance metrics

## Deployment

The service is containerized and can be deployed using Docker:

```bash
docker build -t your-service-name .
docker run -p 8000:8000 your-service-name
```

For production deployment, see the main project documentation.

## Customization Checklist

- [ ] Update service name in all files
- [ ] Modify environment variables
- [ ] Add service-specific models
- [ ] Create API endpoints
- [ ] Add tests
- [ ] Update documentation
- [ ] Configure service communication
- [ ] Add to docker-compose.yml
- [ ] Update API Gateway configuration 