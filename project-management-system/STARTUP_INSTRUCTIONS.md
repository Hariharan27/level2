# Startup Instructions

## Quick Start Guide

This guide will help you get the Project Management System up and running in minutes.

## Prerequisites

Before starting, ensure you have the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Git** (for cloning the repository)

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check Git version
git --version
```

## Step 1: Clone and Setup

### 1.1 Clone the Repository

```bash
git clone <repository-url>
cd project-management-system
```

### 1.2 Copy Environment Files

```bash
# Copy main environment file
cp .env.example .env

# Copy service-specific environment files
cp backend/services/auth-service/.env.example backend/services/auth-service/.env
cp backend/services/user-service/.env.example backend/services/user-service/.env
cp backend/services/project-service/.env.example backend/services/project-service/.env
cp backend/services/task-service/.env.example backend/services/task-service/.env
cp backend/services/time-service/.env.example backend/services/time-service/.env
cp backend/services/file-service/.env.example backend/services/file-service/.env
cp backend/services/comment-service/.env.example backend/services/comment-service/.env
cp backend/services/notification-service/.env.example backend/services/notification-service/.env
cp backend/services/analytics-service/.env.example backend/services/analytics-service/.env
```

### 1.3 Validate Environment Setup

```bash
# Run environment validation script
./infrastructure/scripts/validate-environment.sh
```

### 1.3 Configure Environment Variables

Edit the `.env` file and update the following critical variables:

```bash
# Database password (change this!)
DB_PASSWORD=your_secure_db_password_here

# JWT secret (change this!)
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random

# Email configuration (optional for development)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_email_app_password
```

## Step 2: Start the System

### 2.1 Start All Services

```bash
# Start all services in detached mode
docker-compose up -d

# Or start with logs visible
docker-compose up
```

### 2.2 Verify Services are Running

```bash
# Check service status
docker-compose ps

# Check service logs
docker-compose logs -f
```

Expected output should show all services as "Up":
```
Name                    Command               State           Ports         
--------------------------------------------------------------------------------
analytics-db           docker-entrypoint.sh postgres    Up      5432/tcp
analytics-service      gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8009->8000/tcp
api-gateway           kong start --conf /kong.yml      Up      0.0.0.0:8000->8000/tcp, 0.0.0.0:8001->8001/tcp
auth-db               docker-entrypoint.sh postgres    Up      5432/tcp
auth-service          gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8001->8000/tcp
comment-db            docker-entrypoint.sh postgres    Up      5432/tcp
comment-service       gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8007->8000/tcp
elasticsearch         /usr/local/bin/docker-entr ...   Up      0.0.0.0:9200->9200/tcp
file-service          gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8006->8000/tcp
frontend              docker-entrypoint.sh npm sta    Up      0.0.0.0:3000->3000/tcp
grafana               /run.sh                          Up      0.0.0.0:3001->3000/tcp
minio                 /usr/bin/docker-entrypoint ...   Up      0.0.0.0:9000->9000/tcp, 0.0.0.0:9001->9001/tcp
notification-service  gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8008->8000/tcp
project-db            docker-entrypoint.sh postgres    Up      5432/tcp
project-service       gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8003->8000/tcp
prometheus            /bin/prometheus --config.f ...   Up      0.0.0.0:9090->9090/tcp
rabbitmq              docker-entrypoint.sh rabbit ...  Up      0.0.0.0:15672->15672/tcp, 0.0.0.0:5672->5672/tcp
redis                 docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
task-db               docker-entrypoint.sh postgres    Up      5432/tcp
task-service          gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8004->8000/tcp
time-db               docker-entrypoint.sh postgres    Up      5432/tcp
time-service          gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8005->8000/tcp
user-db               docker-entrypoint.sh postgres    Up      5432/tcp
user-service          gunicorn --bind 0.0.0.0:8000    Up      0.0.0.0:8002->8000/tcp
```

## Step 3: Initialize Databases

### 3.1 Run Database Migrations

```bash
# Run migrations for all services
docker-compose exec auth-service python manage.py migrate
docker-compose exec user-service python manage.py migrate
docker-compose exec project-service python manage.py migrate
docker-compose exec task-service python manage.py migrate
docker-compose exec time-service python manage.py migrate
docker-compose exec comment-service python manage.py migrate
docker-compose exec analytics-service python manage.py migrate
```

### 3.2 Create Superuser

```bash
# Create admin user for authentication service
docker-compose exec auth-service python manage.py createsuperuser
```

Follow the prompts to create your admin account.

## Step 4: Access the Application

### 4.1 Main Application URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | React SPA - Main application |
| **API Gateway** | http://localhost:8000 | Kong Gateway - API access point |
| **Kong Admin** | http://localhost:8001 | Kong administration interface |

### 4.2 Individual Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Auth Service | http://localhost:8001 | Authentication API |
| User Service | http://localhost:8002 | User Management API |
| Project Service | http://localhost:8003 | Project Management API |
| Task Service | http://localhost:8004 | Task Management API |
| Time Service | http://localhost:8005 | Time Tracking API |
| File Service | http://localhost:8006 | File Management API |
| Comment Service | http://localhost:8007 | Comments API |
| Notification Service | http://localhost:8008 | Notifications API |
| Analytics Service | http://localhost:8009 | Analytics API |

### 4.3 Infrastructure Services

| Service | URL | Description |
|---------|-----|-------------|
| **Prometheus** | http://localhost:9090 | Metrics collection |
| **Grafana** | http://localhost:3001 | Metrics visualization |
| **RabbitMQ Management** | http://localhost:15672 | Message queue management |
| **MinIO Console** | http://localhost:9001 | File storage management |
| **Elasticsearch** | http://localhost:9200 | Search and logging |

## Step 5: Verify Installation

### 5.1 Health Checks

Test the health endpoints:

```bash
# Test API Gateway
curl http://localhost:8000/health

# Test individual services
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health
curl http://localhost:8005/health
curl http://localhost:8006/health
curl http://localhost:8007/health
curl http://localhost:8008/health
curl http://localhost:8009/health
```

### 5.2 API Documentation

Access the API documentation:

```bash
# Swagger UI
open http://localhost:8000/docs

# ReDoc
open http://localhost:8000/redoc
```

### 5.3 Frontend Application

Open your browser and navigate to:
```
http://localhost:3000
```

You should see the React frontend application.

## Step 6: Development Workflow

### 6.1 View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f auth-service
docker-compose logs -f frontend
```

### 6.2 Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart auth-service
```

### 6.3 Stop the System

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

## Troubleshooting

### Common Issues

#### 1. Port Conflicts

If you get port conflicts, check what's running on the ports:

```bash
# Check what's using port 3000
lsof -i :3000

# Check what's using port 8000
lsof -i :8000
```

#### 2. Database Connection Issues

```bash
# Check database containers
docker-compose ps | grep db

# Check database logs
docker-compose logs auth-db
```

#### 3. Service Startup Issues

```bash
# Check service logs
docker-compose logs auth-service

# Check service health
docker-compose exec auth-service curl -f http://localhost:8000/health
```

#### 4. Memory Issues

If you encounter memory issues, increase Docker memory allocation:

1. Open Docker Desktop
2. Go to Settings > Resources
3. Increase memory allocation to at least 4GB

### Reset Everything

If you need to start fresh:

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker system prune -a

# Start again
docker-compose up -d
```

## Next Steps

### 1. Explore the Application

- Navigate to http://localhost:3000
- Create a new account or login with the superuser
- Explore the different features

### 2. Check Monitoring

- Visit http://localhost:3001 (Grafana) to see metrics
- Check http://localhost:9090 (Prometheus) for raw metrics

### 3. Review Documentation

- Check the API documentation at http://localhost:8000/docs
- Review service-specific README files in each service directory

### 4. Start Development

- Each service can be developed independently
- Use the service templates for adding new services
- Follow the development guidelines in each service README

## Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review service-specific logs
3. Check the project documentation
4. Open an issue in the project repository

The system is now ready for development and testing! 🚀 