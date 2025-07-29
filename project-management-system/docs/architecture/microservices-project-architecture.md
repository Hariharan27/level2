# Project Management System - Microservices Architecture

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Microservices Breakdown](#microservices-breakdown)
3. [Database Design](#database-design)
4. [API Gateway & BFF Layer](#api-gateway--bff-layer)
5. [Authentication & Authorization](#authentication--authorization)
6. [File Upload Strategy](#file-upload-strategy)
7. [Real-time Collaboration](#real-time-collaboration)
8. [Notification System](#notification-system)
9. [Deployment & Infrastructure](#deployment--infrastructure)
10. [Monitoring & Observability](#monitoring--observability)

---

## Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  React SPA                                                      │
│  ├── Project Dashboard                                          │
│  ├── Task Management Interface                                  │
│  ├── Time Tracking Module                                       │
│  ├── Team Collaboration Tools                                   │
│  └── Real-time Updates (WebSocket)                             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTPS/REST API + WebSocket
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  Kong/Ambassador API Gateway                                   │
│  ├── Route Management & Load Balancing                         │
│  ├── Authentication & Authorization                            │
│  ├── Rate Limiting & Throttling                                │
│  ├── Request/Response Transformation                           │
│  └── API Documentation (Swagger)                               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    MICROSERVICES LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Auth Service│  │User Service │  │Project Svc  │             │
│  │ (Django)    │  │ (Django)    │  │ (Django)    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │Task Service │  │Time Tracking│  │File Service │             │
│  │ (Django)    │  │ Service     │  │ (Django)    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │Comment Svc  │  │Notification│  │Analytics    │             │
│  │ (Django)    │  │ Service     │  │ Service     │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Auth DB     │  │ User DB     │  │ Project DB  │             │
│  │(PostgreSQL) │  │(PostgreSQL) │  │(PostgreSQL) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Task DB     │  │ Time DB     │  │ File Store  │             │
│  │(PostgreSQL) │  │(PostgreSQL) │  │(S3/MinIO)   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Comment DB  │  │ Notification│  │ Analytics   │             │
│  │(PostgreSQL) │  │ DB (Redis)  │  │ DB (Timescale│             │
│  └─────────────┘  └─────────────┘  │ DB)         │             │
│                                    └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│  Redis (Caching & Session Store)                               │
│  RabbitMQ/Kafka (Message Queue)                                 │
│  Elasticsearch (Search & Logging)                               │
│  Prometheus + Grafana (Monitoring)                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Microservices Breakdown

### 1. Authentication Service
**Purpose**: Handle user authentication, authorization, and session management

**Responsibilities**:
- User registration and login
- JWT token generation and validation
- OAuth2 integration (Google, GitHub, Slack)
- Role-based access control (RBAC)
- Session management
- Password reset and email verification

**API Endpoints**:
```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
POST /api/v1/auth/forgot-password
POST /api/v1/auth/reset-password
GET  /api/v1/auth/profile
PUT  /api/v1/auth/profile
```

**Database Schema**:
```sql
-- auth_db
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. User Service
**Purpose**: Manage user profiles, teams, and organizational structure

**Responsibilities**:
- User profile management
- Team creation and management
- Organization structure
- User preferences and settings
- Team member invitations
- User search and discovery

**API Endpoints**:
```
GET    /api/v1/users
GET    /api/v1/users/{id}
PUT    /api/v1/users/{id}
DELETE /api/v1/users/{id}
GET    /api/v1/users/{id}/teams
POST   /api/v1/teams
GET    /api/v1/teams
GET    /api/v1/teams/{id}
PUT    /api/v1/teams/{id}
DELETE /api/v1/teams/{id}
POST   /api/v1/teams/{id}/members
DELETE /api/v1/teams/{id}/members/{user_id}
```

**Database Schema**:
```sql
-- user_db
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    timezone VARCHAR(50),
    language VARCHAR(10),
    notification_preferences JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    owner_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id),
    user_id UUID NOT NULL,
    role VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    settings JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Project Service
**Purpose**: Manage projects, milestones, and project-level operations

**Responsibilities**:
- Project CRUD operations
- Milestone management
- Project templates
- Project analytics and reporting
- Project settings and configuration
- Project member management

**API Endpoints**:
```
GET    /api/v1/projects
POST   /api/v1/projects
GET    /api/v1/projects/{id}
PUT    /api/v1/projects/{id}
DELETE /api/v1/projects/{id}
GET    /api/v1/projects/{id}/milestones
POST   /api/v1/projects/{id}/milestones
GET    /api/v1/projects/{id}/analytics
GET    /api/v1/projects/{id}/members
POST   /api/v1/projects/{id}/members
```

**Database Schema**:
```sql
-- project_db
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    owner_id UUID NOT NULL,
    team_id UUID,
    settings JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id),
    user_id UUID NOT NULL,
    role VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE project_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_data JSONB,
    created_by UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. Task Service
**Purpose**: Handle task management, assignments, and task-related operations

**Responsibilities**:
- Task CRUD operations
- Task assignment and reassignment
- Task status management
- Task dependencies
- Task templates
- Task search and filtering

**API Endpoints**:
```
GET    /api/v1/tasks
POST   /api/v1/tasks
GET    /api/v1/tasks/{id}
PUT    /api/v1/tasks/{id}
DELETE /api/v1/tasks/{id}
GET    /api/v1/tasks/{id}/dependencies
POST   /api/v1/tasks/{id}/dependencies
PUT    /api/v1/tasks/{id}/assign
PUT    /api/v1/tasks/{id}/status
GET    /api/v1/projects/{project_id}/tasks
```

**Database Schema**:
```sql
-- task_db
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    project_id UUID NOT NULL,
    assigned_to UUID,
    created_by UUID NOT NULL,
    status VARCHAR(50) DEFAULT 'todo',
    priority VARCHAR(20) DEFAULT 'medium',
    due_date TIMESTAMP,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id),
    depends_on_task_id UUID REFERENCES tasks(id),
    dependency_type VARCHAR(50) DEFAULT 'finish_to_start',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_data JSONB,
    created_by UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id),
    file_id UUID NOT NULL,
    uploaded_by UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5. Time Tracking Service
**Purpose**: Handle time logging, time sheets, and time-related analytics

**Responsibilities**:
- Time entry creation and management
- Time sheet generation
- Time analytics and reporting
- Billable hours tracking
- Time approval workflow
- Integration with task service

**API Endpoints**:
```
GET    /api/v1/time-entries
POST   /api/v1/time-entries
GET    /api/v1/time-entries/{id}
PUT    /api/v1/time-entries/{id}
DELETE /api/v1/time-entries/{id}
GET    /api/v1/timesheets
POST   /api/v1/timesheets
GET    /api/v1/timesheets/{id}
PUT    /api/v1/timesheets/{id}/approve
GET    /api/v1/time-analytics
```

**Database Schema**:
```sql
-- time_db
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    task_id UUID,
    project_id UUID,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_minutes INTEGER,
    billable BOOLEAN DEFAULT TRUE,
    hourly_rate DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE timesheets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    week_start_date DATE NOT NULL,
    total_hours DECIMAL(5,2),
    status VARCHAR(50) DEFAULT 'draft',
    approved_by UUID,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE timesheet_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timesheet_id UUID REFERENCES timesheets(id),
    time_entry_id UUID REFERENCES time_entries(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hourly_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    project_id UUID,
    rate DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6. File Service
**Purpose**: Handle file uploads, storage, and file management

**Responsibilities**:
- File upload and download
- File metadata management
- File versioning
- File sharing and permissions
- File search and indexing
- Integration with cloud storage (S3/MinIO)

**API Endpoints**:
```
POST   /api/v1/files/upload
GET    /api/v1/files/{id}
DELETE /api/v1/files/{id}
GET    /api/v1/files/{id}/download
PUT    /api/v1/files/{id}/share
GET    /api/v1/files/search
POST   /api/v1/files/{id}/versions
```

**Database Schema**:
```sql
-- file_db
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    uploaded_by UUID NOT NULL,
    project_id UUID,
    task_id UUID,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID REFERENCES files(id),
    shared_with UUID NOT NULL,
    permission VARCHAR(20) DEFAULT 'read',
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID REFERENCES files(id),
    version_number INTEGER NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 7. Comment Service
**Purpose**: Handle comments, discussions, and collaboration features

**Responsibilities**:
- Comment creation and management
- Threaded discussions
- Comment notifications
- Comment search
- Integration with tasks and projects

**API Endpoints**:
```
GET    /api/v1/comments
POST   /api/v1/comments
GET    /api/v1/comments/{id}
PUT    /api/v1/comments/{id}
DELETE /api/v1/comments/{id}
GET    /api/v1/tasks/{task_id}/comments
GET    /api/v1/projects/{project_id}/comments
POST   /api/v1/comments/{id}/replies
```

**Database Schema**:
```sql
-- comment_db
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    author_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'task', 'project', 'milestone'
    entity_id UUID NOT NULL,
    parent_comment_id UUID REFERENCES comments(id),
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID REFERENCES comments(id),
    user_id UUID NOT NULL,
    reaction_type VARCHAR(20) NOT NULL, -- 'like', 'heart', 'thumbs_up'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment_mentions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID REFERENCES comments(id),
    mentioned_user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 8. Notification Service
**Purpose**: Handle all types of notifications and real-time updates

**Responsibilities**:
- Email notifications
- In-app notifications
- Push notifications
- Notification preferences
- Notification templates
- Real-time delivery

**API Endpoints**:
```
GET    /api/v1/notifications
POST   /api/v1/notifications
PUT    /api/v1/notifications/{id}/read
DELETE /api/v1/notifications/{id}
GET    /api/v1/notifications/preferences
PUT    /api/v1/notifications/preferences
```

**Database Schema**:
```sql
-- notification_db (Redis)
-- Using Redis for fast access and TTL support

-- Hash: user:{user_id}:notifications
-- Fields: notification_id -> notification_data (JSON)

-- Hash: user:{user_id}:preferences
-- Fields: notification_type -> enabled (boolean)

-- Set: user:{user_id}:unread_notifications
-- Members: notification_ids

-- Hash: notification:{notification_id}
-- Fields: 
--   - type: notification_type
--   - title: notification_title
--   - message: notification_message
--   - data: additional_data (JSON)
--   - created_at: timestamp
--   - expires_at: timestamp
```

### 9. Analytics Service
**Purpose**: Handle analytics, reporting, and data aggregation

**Responsibilities**:
- Project analytics
- Time tracking analytics
- Team performance metrics
- Custom reports
- Data visualization
- Export functionality

**API Endpoints**:
```
GET    /api/v1/analytics/projects/{project_id}
GET    /api/v1/analytics/users/{user_id}
GET    /api/v1/analytics/teams/{team_id}
GET    /api/v1/analytics/time-tracking
GET    /api/v1/analytics/custom-reports
POST   /api/v1/analytics/reports
```

**Database Schema**:
```sql
-- analytics_db (TimescaleDB for time-series data)
CREATE TABLE project_metrics (
    time TIMESTAMPTZ NOT NULL,
    project_id UUID NOT NULL,
    total_tasks INTEGER,
    completed_tasks INTEGER,
    total_hours DECIMAL(10,2),
    team_size INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_metrics (
    time TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    tasks_completed INTEGER,
    hours_logged DECIMAL(10,2),
    productivity_score DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE time_analytics (
    time TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    project_id UUID,
    task_id UUID,
    hours_logged DECIMAL(5,2),
    billable_hours DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## API Gateway & BFF Layer

### Kong API Gateway Configuration

```yaml
# kong.yml
_format_version: "2.1"

services:
  - name: auth-service
    url: http://auth-service:8000
    routes:
      - name: auth-routes
        paths: ["/api/v1/auth"]
    plugins:
      - name: rate-limiting
        config:
          minute: 100
      - name: cors
        config:
          origins: ["http://localhost:3000"]

  - name: user-service
    url: http://user-service:8000
    routes:
      - name: user-routes
        paths: ["/api/v1/users", "/api/v1/teams"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: project-service
    url: http://project-service:8000
    routes:
      - name: project-routes
        paths: ["/api/v1/projects"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: task-service
    url: http://task-service:8000
    routes:
      - name: task-routes
        paths: ["/api/v1/tasks"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: time-service
    url: http://time-service:8000
    routes:
      - name: time-routes
        paths: ["/api/v1/time-entries", "/api/v1/timesheets"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: file-service
    url: http://file-service:8000
    routes:
      - name: file-routes
        paths: ["/api/v1/files"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: comment-service
    url: http://comment-service:8000
    routes:
      - name: comment-routes
        paths: ["/api/v1/comments"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: notification-service
    url: http://notification-service:8000
    routes:
      - name: notification-routes
        paths: ["/api/v1/notifications"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}

  - name: analytics-service
    url: http://analytics-service:8000
    routes:
      - name: analytics-routes
        paths: ["/api/v1/analytics"]
    plugins:
      - name: jwt
        config:
          secret: ${JWT_SECRET}
```

---

## Authentication & Authorization

### JWT Token Structure

```python
# JWT Payload Structure
{
    "user_id": "uuid",
    "email": "user@example.com",
    "username": "username",
    "roles": ["admin", "manager", "developer"],
    "permissions": ["read:projects", "write:tasks", "delete:files"],
    "team_id": "uuid",
    "organization_id": "uuid",
    "iat": 1640995200,
    "exp": 1641081600,
    "jti": "unique_token_id"
}
```

### Service-to-Service Authentication

```python
# Service authentication middleware
class ServiceAuthMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Validate service-to-service tokens
        if 'X-Service-Token' in request.headers:
            service_token = request.headers['X-Service-Token']
            if not self.validate_service_token(service_token):
                return JsonResponse({'error': 'Invalid service token'}, status=401)
        
        return self.get_response(request)
```

---

## File Upload Strategy

### Multi-Cloud Storage Approach

```python
# File service configuration
STORAGE_CONFIG = {
    'default': 's3',
    'backup': 'minio',
    'providers': {
        's3': {
            'bucket': 'project-files',
            'region': 'us-east-1',
            'access_key': os.getenv('AWS_ACCESS_KEY'),
            'secret_key': os.getenv('AWS_SECRET_KEY'),
        },
        'minio': {
            'endpoint': 'minio:9000',
            'bucket': 'project-files-backup',
            'access_key': os.getenv('MINIO_ACCESS_KEY'),
            'secret_key': os.getenv('MINIO_SECRET_KEY'),
        }
    }
}

# File upload workflow
class FileUploadService:
    def upload_file(self, file, user_id, project_id=None, task_id=None):
        # 1. Validate file
        # 2. Generate unique filename
        # 3. Upload to primary storage (S3)
        # 4. Upload to backup storage (MinIO)
        # 5. Store metadata in database
        # 6. Trigger notifications
        pass
```

---

## Real-time Collaboration

### WebSocket Implementation

```python
# Django Channels configuration
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [('redis', 6379)],
        },
    },
}

# WebSocket consumers
class ProjectConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.project_id = self.scope['url_route']['kwargs']['project_id']
        self.room_group_name = f'project_{self.project_id}'
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type')
        
        if message_type == 'task_update':
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'task_update',
                    'data': data['data']
                }
            )

    async def task_update(self, event):
        await self.send(text_data=json.dumps(event['data']))
```

---

## Notification System

### Notification Types and Delivery

```python
# Notification service
class NotificationService:
    def send_notification(self, user_id, notification_type, data):
        # 1. Create notification record
        # 2. Check user preferences
        # 3. Send via appropriate channels
        # 4. Update real-time status
        
        notification = {
            'id': str(uuid.uuid4()),
            'type': notification_type,
            'user_id': user_id,
            'data': data,
            'created_at': datetime.utcnow().isoformat(),
            'read': False
        }
        
        # Store in Redis
        redis_client.hset(f"user:{user_id}:notifications", 
                         notification['id'], json.dumps(notification))
        
        # Send real-time notification
        await self.send_websocket_notification(user_id, notification)
        
        # Send email if enabled
        if self.should_send_email(user_id, notification_type):
            await self.send_email_notification(user_id, notification)
```

---

## Deployment & Infrastructure

### Docker Compose Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  api-gateway:
    image: kong:3.4
    ports:
      - "8000:8000"
      - "8001:8001"
    environment:
      KONG_DATABASE: "off"
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: "0.0.0.0:8001"
    volumes:
      - ./kong.yml:/kong.yml
    command: kong start --conf /kong.yml

  # Microservices
  auth-service:
    build: ./services/auth-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@auth-db:5432/auth_db
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - auth-db
      - redis

  user-service:
    build: ./services/user-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@user-db:5432/user_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - user-db
      - redis

  project-service:
    build: ./services/project-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@project-db:5432/project_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - project-db
      - redis

  task-service:
    build: ./services/task-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@task-db:5432/task_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - task-db
      - redis

  time-service:
    build: ./services/time-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@time-db:5432/time_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - time-db
      - redis

  file-service:
    build: ./services/file-service
    environment:
      - AWS_ACCESS_KEY=${AWS_ACCESS_KEY}
      - AWS_SECRET_KEY=${AWS_SECRET_KEY}
      - S3_BUCKET=${S3_BUCKET}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis

  comment-service:
    build: ./services/comment-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@comment-db:5432/comment_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - comment-db
      - redis

  notification-service:
    build: ./services/notification-service
    environment:
      - REDIS_URL=redis://redis:6379
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_PORT=${SMTP_PORT}
      - SMTP_USERNAME=${SMTP_USERNAME}
      - SMTP_PASSWORD=${SMTP_PASSWORD}
    depends_on:
      - redis

  analytics-service:
    build: ./services/analytics-service
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@analytics-db:5432/analytics_db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - analytics-db
      - redis

  # Databases
  auth-db:
    image: postgres:15
    environment:
      POSTGRES_DB: auth_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - auth_data:/var/lib/postgresql/data

  user-db:
    image: postgres:15
    environment:
      POSTGRES_DB: user_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - user_data:/var/lib/postgresql/data

  project-db:
    image: postgres:15
    environment:
      POSTGRES_DB: project_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - project_data:/var/lib/postgresql/data

  task-db:
    image: postgres:15
    environment:
      POSTGRES_DB: task_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - task_data:/var/lib/postgresql/data

  time-db:
    image: postgres:15
    environment:
      POSTGRES_DB: time_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - time_data:/var/lib/postgresql/data

  comment-db:
    image: postgres:15
    environment:
      POSTGRES_DB: comment_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - comment_data:/var/lib/postgresql/data

  analytics-db:
    image: timescale/timescaledb:latest-pg15
    environment:
      POSTGRES_DB: analytics_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - analytics_data:/var/lib/postgresql/data

  # Infrastructure Services
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  # Frontend
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - api-gateway

volumes:
  auth_data:
  user_data:
  project_data:
  task_data:
  time_data:
  comment_data:
  analytics_data:
  elasticsearch_data:
```

---

## Monitoring & Observability

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway:8001']

  - job_name: 'auth-service'
    static_configs:
      - targets: ['auth-service:8000']

  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:8000']

  - job_name: 'project-service'
    static_configs:
      - targets: ['project-service:8000']

  - job_name: 'task-service'
    static_configs:
      - targets: ['task-service:8000']

  - job_name: 'time-service'
    static_configs:
      - targets: ['time-service:8000']

  - job_name: 'file-service'
    static_configs:
      - targets: ['file-service:8000']

  - job_name: 'comment-service'
    static_configs:
      - targets: ['comment-service:8000']

  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service:8000']

  - job_name: 'analytics-service'
    static_configs:
      - targets: ['analytics-service:8000']
```

### Logging Strategy

```python
# Centralized logging configuration
LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'json': {
            'format': '{"timestamp": "%(asctime)s", "level": "%(levelname)s", "service": "%(name)s", "message": "%(message)s"}'
        }
    },
    'handlers': {
        'elasticsearch': {
            'class': 'elasticsearch_handler.ElasticsearchHandler',
            'hosts': ['elasticsearch:9200'],
            'index': 'project-management-logs',
            'formatter': 'json'
        }
    },
    'root': {
        'handlers': ['elasticsearch'],
        'level': 'INFO'
    }
}
```

---

## Summary

This microservices architecture provides:

### **Key Benefits:**
1. **Scalability**: Each service can scale independently
2. **Maintainability**: Clear separation of concerns
3. **Technology Flexibility**: Different services can use different technologies
4. **Team Independence**: Teams can work on different services
5. **Fault Isolation**: Service failures don't affect the entire system

### **Implementation Priority:**
1. **Phase 1**: Core services (Auth, User, Project, Task)
2. **Phase 2**: Supporting services (Time, File, Comment)
3. **Phase 3**: Advanced services (Notification, Analytics)
4. **Phase 4**: Infrastructure and monitoring

### **Technology Stack Summary:**
- **Frontend**: React SPA with WebSocket support
- **Backend**: Django microservices with DRF
- **Database**: PostgreSQL (multiple instances) + Redis + TimescaleDB
- **API Gateway**: Kong for routing and security
- **Message Queue**: RabbitMQ for async communication
- **Storage**: S3/MinIO for file storage
- **Monitoring**: Prometheus + Grafana + Elasticsearch
- **Deployment**: Docker + Docker Compose

This architecture ensures high scalability, maintainability, and supports real-time collaboration while maintaining clear service boundaries and easy integration with third-party tools. 