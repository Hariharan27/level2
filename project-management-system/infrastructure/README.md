# Infrastructure - Project Management System

## Overview

This directory contains all infrastructure-related components for the Project Management System, including configuration files, deployment scripts, and infrastructure management tools.

## Architecture

The infrastructure is designed to support a microservices architecture with:

- **API Gateway**: Kong for routing and load balancing
- **Container Orchestration**: Docker Compose for local development
- **Monitoring**: Prometheus and Grafana
- **Caching**: Redis
- **Message Queue**: RabbitMQ
- **Search**: Elasticsearch
- **File Storage**: MinIO (S3-compatible)
- **Reverse Proxy**: Nginx for frontend

## Directory Structure

```
infrastructure/
├── config/                    # Configuration files
│   ├── kong/                 # API Gateway configuration
│   │   └── kong.yml         # Kong routes and services
│   ├── grafana/              # Grafana configuration
│   │   └── provisioning/     # Datasources and dashboards
│   ├── nginx/                # Nginx configuration
│   └── prometheus.yml        # Prometheus monitoring config
├── scripts/                   # Utility scripts
│   └── validate-environment.sh # Environment validation
├── deployment/                # Deployment configurations
│   ├── docker/               # Docker deployment files
│   ├── kubernetes/           # Kubernetes manifests
│   └── terraform/            # Infrastructure as Code
└── README.md                 # This file
```

## Configuration Files

### Kong API Gateway

**Location**: `config/kong/kong.yml`

**Purpose**: Routes API requests to appropriate microservices

**Features**:
- Service discovery and routing
- Authentication and authorization
- Rate limiting
- CORS handling
- Request/response transformation

**Configuration**:
```yaml
services:
  - name: auth-service
    url: http://auth-service:8000
    routes:
      - name: auth-routes
        paths: ["/api/v1/auth"]
```

### Prometheus Monitoring

**Location**: `config/prometheus.yml`

**Purpose**: Collects metrics from all services

**Features**:
- Service health monitoring
- Performance metrics
- Custom business metrics
- Alerting rules

**Targets**:
- All microservices (auth, user, project, task, etc.)
- Infrastructure services (Redis, RabbitMQ, databases)
- API Gateway (Kong)

### Grafana Dashboards

**Location**: `config/grafana/`

**Purpose**: Visualization and monitoring dashboards

**Features**:
- Service performance dashboards
- Business metrics visualization
- Alert management
- Custom dashboards

### Nginx Configuration

**Location**: `config/nginx/`

**Purpose**: Reverse proxy and load balancing

**Features**:
- Static file serving
- Load balancing
- SSL termination
- Security headers

## Scripts

### Environment Validation

**Location**: `scripts/validate-environment.sh`

**Purpose**: Validates environment setup before deployment

**Checks**:
- Docker and Docker Compose installation
- Required environment variables
- Port availability
- Network connectivity

**Usage**:
```bash
./scripts/validate-environment.sh
```

## Deployment

### Docker Compose

**Location**: Root directory (`docker-compose.yml`)

**Purpose**: Local development and testing

**Services**:
- 9 microservices (auth, user, project, task, etc.)
- Frontend React application
- Infrastructure services (Redis, RabbitMQ, etc.)
- Monitoring stack (Prometheus, Grafana)

**Usage**:
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up auth-service user-service

# View logs
docker-compose logs -f
```

### Kubernetes Deployment

**Location**: `deployment/kubernetes/`

**Purpose**: Production deployment

**Components**:
- Service manifests
- Deployment configurations
- Ingress rules
- ConfigMaps and Secrets

### Terraform Infrastructure

**Location**: `deployment/terraform/`

**Purpose**: Infrastructure as Code

**Resources**:
- Cloud infrastructure (AWS, GCP, Azure)
- Database instances
- Load balancers
- Security groups

## Environment Variables

### Required Variables

```bash
# Database
DB_PASSWORD=your_secure_db_password

# JWT
JWT_SECRET=your_jwt_secret_key

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_app_password

# AWS/MinIO
AWS_ACCESS_KEY=your_access_key
AWS_SECRET_KEY=your_secret_key
S3_BUCKET=project-files

# RabbitMQ
RABBITMQ_PASSWORD=rabbitmq_password

# Grafana
GRAFANA_PASSWORD=grafana_password
```

## Monitoring

### Health Checks

Each service provides health check endpoints:

```bash
# Service health
GET /health

# Response
{
    "status": "healthy",
    "service": "auth-service",
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
}
```

### Metrics

Prometheus metrics are exposed at `/metrics`:

```bash
# Service metrics
GET /metrics

# Example metrics
http_requests_total{method="GET",status="200"} 1234
http_request_duration_seconds{quantile="0.5"} 0.1
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

### Network Security

- **Service isolation**: Each service runs in its own container
- **Network segmentation**: Microservices network for internal communication
- **API Gateway**: Single entry point with authentication

### Access Control

- **JWT authentication**: Token-based authentication
- **Role-based access**: RBAC for different user roles
- **Service-to-service**: Internal service authentication

### Data Protection

- **Encryption**: TLS for all external communications
- **Secrets management**: Environment variables for sensitive data
- **Input validation**: All inputs are validated and sanitized

## Performance

### Caching Strategy

- **Redis**: Session storage and API response caching
- **Database**: Query result caching
- **CDN**: Static asset caching

### Load Balancing

- **Kong API Gateway**: Load balancing across services
- **Nginx**: Reverse proxy for frontend
- **Database**: Connection pooling

### Scaling

- **Horizontal scaling**: Services can be scaled independently
- **Database scaling**: Read replicas for analytics
- **Cache scaling**: Redis cluster for high availability

## Troubleshooting

### Common Issues

1. **Service not starting**:
   ```bash
   # Check service logs
   docker-compose logs service-name
   
   # Check environment variables
   docker-compose exec service-name env
   ```

2. **Database connection issues**:
   ```bash
   # Check database status
   docker-compose ps
   
   # Check database logs
   docker-compose logs database-name
   ```

3. **Network connectivity**:
   ```bash
   # Check network
   docker network ls
   
   # Test connectivity
   docker-compose exec service-name ping other-service
   ```

### Monitoring Commands

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs -f service-name

# Check service health
curl http://localhost:8001/health

# View metrics
curl http://localhost:8001/metrics
```

## Best Practices

1. **Configuration Management**: Use environment variables for configuration
2. **Security**: Implement proper authentication and authorization
3. **Monitoring**: Comprehensive logging and metrics collection
4. **Backup**: Regular database and configuration backups
5. **Documentation**: Keep infrastructure documentation updated
6. **Testing**: Test infrastructure changes in staging environment
7. **Version Control**: Track all configuration changes
8. **Automation**: Automate deployment and configuration management

## Contributing

1. Follow infrastructure as code principles
2. Test configuration changes locally
3. Update documentation for new components
4. Use consistent naming conventions
5. Implement proper error handling
6. Add monitoring for new services 