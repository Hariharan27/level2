# Project Management Application - System Architecture

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Component Breakdown](#component-breakdown)
3. [Technology Stack](#technology-stack)
4. [Database Design](#database-design)
5. [API Design](#api-design)
6. [Security Implementation](#security-implementation)
7. [Deployment Architecture](#deployment-architecture)
8. [Future Extensions](#future-extensions)

---

## System Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  React SPA (Frontend)                                          │
│  ├── Authentication Module                                     │
│  ├── Project Management Module                                 │
│  ├── Task Management Module                                    │
│  ├── User Management Module                                    │
│  └── Shared Components                                         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTPS/REST API
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  Nginx (Reverse Proxy, Load Balancer)                          │
│  ├── Rate Limiting                                             │
│  ├── SSL Termination                                           │
│  └── Static File Serving                                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     APPLICATION LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Django REST Framework (Backend)                               │
│  ├── Authentication Service                                    │
│  ├── Project Service                                           │
│  ├── Task Service                                              │
│  ├── User Service                                              │
│  └── Notification Service                                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL (Primary Database)                                 │
│  Redis (Caching & Session Store)                               │
│  └── Future: WebSocket Support                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### Backend Architecture (Django)

#### Folder Structure
```
project_management/
├── manage.py
├── requirements.txt
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── .gitignore
├── project_management/          # Main Django project
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   ├── production.py
│   │   └── test.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/                        # Django apps
│   ├── __init__.py
│   ├── authentication/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── permissions.py
│   │   └── tests/
│   ├── projects/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── permissions.py
│   │   └── tests/
│   ├── tasks/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── permissions.py
│   │   └── tests/
│   └── users/
│       ├── __init__.py
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       ├── services.py
│       ├── permissions.py
│       └── tests/
├── core/                        # Shared utilities
│   ├── __init__.py
│   ├── middleware.py
│   ├── permissions.py
│   ├── exceptions.py
│   ├── utils.py
│   └── pagination.py
├── static/
├── media/
└── templates/
```

#### Frontend Architecture (React)

#### Folder Structure
```
frontend/
├── package.json
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── index.js
│   ├── App.js
│   ├── index.css
│   ├── components/              # Reusable components
│   │   ├── common/
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Modal.jsx
│   │   │   ├── Loading.jsx
│   │   │   └── ErrorBoundary.jsx
│   │   ├── layout/
│   │   │   ├── Header.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Footer.jsx
│   │   │   └── Layout.jsx
│   │   └── forms/
│   │       ├── LoginForm.jsx
│   │       ├── SignupForm.jsx
│   │       ├── ProjectForm.jsx
│   │       └── TaskForm.jsx
│   ├── pages/                   # Page components
│   │   ├── auth/
│   │   │   ├── Login.jsx
│   │   │   └── Signup.jsx
│   │   ├── dashboard/
│   │   │   └── Dashboard.jsx
│   │   ├── projects/
│   │   │   ├── ProjectList.jsx
│   │   │   ├── ProjectDetail.jsx
│   │   │   └── ProjectCreate.jsx
│   │   └── tasks/
│   │       ├── TaskList.jsx
│   │       ├── TaskDetail.jsx
│   │       └── TaskCreate.jsx
│   ├── services/                # API services
│   │   ├── api.js
│   │   ├── authService.js
│   │   ├── projectService.js
│   │   ├── taskService.js
│   │   └── userService.js
│   ├── hooks/                   # Custom hooks
│   │   ├── useAuth.js
│   │   ├── useApi.js
│   │   └── useLocalStorage.js
│   ├── context/                 # React context
│   │   ├── AuthContext.js
│   │   └── ThemeContext.js
│   ├── utils/                   # Utility functions
│   │   ├── constants.js
│   │   ├── helpers.js
│   │   └── validators.js
│   └── styles/                  # CSS/SCSS files
│       ├── components/
│       └── pages/
├── .env
├── .env.example
└── README.md
```

---

## Technology Stack

### Backend (Django)
```python
# requirements.txt
Django==4.2.7
djangorestframework==3.14.0
djangorestframework-simplejwt==5.3.0
django-cors-headers==4.3.1
django-filter==23.3
psycopg2-binary==2.9.7
redis==5.0.1
celery==5.3.4
django-celery-beat==2.5.0
Pillow==10.1.0
python-decouple==3.8
gunicorn==21.2.0
whitenoise==6.6.0
django-extensions==3.2.3
pytest-django==4.7.0
factory-boy==3.3.0
```

### Frontend (React)
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "axios": "^1.6.0",
    "react-query": "^3.39.3",
    "react-hook-form": "^7.48.2",
    "yup": "^1.3.3",
    "@hookform/resolvers": "^3.3.2",
    "react-hot-toast": "^2.4.1",
    "date-fns": "^2.30.0",
    "react-datepicker": "^4.25.0",
    "react-select": "^5.8.0",
    "react-beautiful-dnd": "^13.1.1",
    "socket.io-client": "^4.7.2"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.1.0",
    "vite": "^4.5.0",
    "eslint": "^8.54.0",
    "prettier": "^3.1.0",
    "tailwindcss": "^3.3.6",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32"
  }
}
```

---

## Database Design

### Core Models

#### User Model
```python
# apps/users/models.py
class User(AbstractUser):
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('manager', 'Manager'),
        ('developer', 'Developer'),
    ]
    
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='developer')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    bio = models.TextField(max_length=500, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### Project Model
```python
# apps/projects/models.py
class Project(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('on_hold', 'On Hold'),
        ('cancelled', 'Cancelled'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    start_date = models.DateField()
    end_date = models.DateField()
    manager = models.ForeignKey(User, on_delete=models.CASCADE, related_name='managed_projects')
    members = models.ManyToManyField(User, related_name='projects')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### Task Model
```python
# apps/tasks/models.py
class Task(models.Model):
    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]
    
    STATUS_CHOICES = [
        ('todo', 'To Do'),
        ('in_progress', 'In Progress'),
        ('review', 'Review'),
        ('done', 'Done'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='tasks')
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_tasks')
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_tasks')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='todo')
    due_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### Comment Model
```python
class Comment(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

---

## API Design

### RESTful Endpoints

#### Authentication Endpoints
```
POST /api/v1/auth/login/          # User login
POST /api/v1/auth/signup/         # User registration
POST /api/v1/auth/refresh/        # Refresh JWT token
POST /api/v1/auth/logout/         # User logout
GET  /api/v1/auth/profile/        # Get user profile
PUT  /api/v1/auth/profile/        # Update user profile
```

#### Project Endpoints
```
GET    /api/v1/projects/          # List projects
POST   /api/v1/projects/          # Create project
GET    /api/v1/projects/{id}/     # Get project details
PUT    /api/v1/projects/{id}/     # Update project
DELETE /api/v1/projects/{id}/     # Delete project
GET    /api/v1/projects/{id}/tasks/ # Get project tasks
```

#### Task Endpoints
```
GET    /api/v1/tasks/             # List tasks
POST   /api/v1/tasks/             # Create task
GET    /api/v1/tasks/{id}/        # Get task details
PUT    /api/v1/tasks/{id}/        # Update task
DELETE /api/v1/tasks/{id}/        # Delete task
GET    /api/v1/tasks/{id}/comments/ # Get task comments
POST   /api/v1/tasks/{id}/comments/ # Add comment
```

#### User Endpoints
```
GET    /api/v1/users/             # List users (admin only)
GET    /api/v1/users/{id}/        # Get user details
PUT    /api/v1/users/{id}/        # Update user (admin/self)
DELETE /api/v1/users/{id}/        # Delete user (admin only)
```

### Service Layer Pattern

#### Project Service
```python
# apps/projects/services.py
class ProjectService:
    @staticmethod
    def create_project(data, user):
        """Create a new project with proper validation"""
        serializer = ProjectSerializer(data=data)
        if serializer.is_valid():
            project = serializer.save(manager=user)
            project.members.add(user)
            return project, None
        return None, serializer.errors
    
    @staticmethod
    def get_user_projects(user):
        """Get projects based on user role"""
        if user.role == 'admin':
            return Project.objects.all()
        elif user.role == 'manager':
            return Project.objects.filter(Q(manager=user) | Q(members=user))
        else:
            return Project.objects.filter(members=user)
```

#### Task Service
```python
# apps/tasks/services.py
class TaskService:
    @staticmethod
    def create_task(data, user):
        """Create a new task with validation"""
        serializer = TaskSerializer(data=data)
        if serializer.is_valid():
            task = serializer.save(created_by=user)
            return task, None
        return None, serializer.errors
    
    @staticmethod
    def update_task_status(task_id, status, user):
        """Update task status with permission check"""
        try:
            task = Task.objects.get(id=task_id)
            if TaskService.can_update_task(task, user):
                task.status = status
                task.save()
                return task, None
            return None, "Permission denied"
        except Task.DoesNotExist:
            return None, "Task not found"
```

---

## Security Implementation

### Authentication & Authorization

#### JWT Configuration
```python
# settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    },
}

# JWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}
```

#### Custom Permissions
```python
# apps/authentication/permissions.py
class IsProjectMember(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.members.filter(id=request.user.id).exists()

class IsTaskAssignee(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.assigned_to == request.user or obj.created_by == request.user

class IsAdminUser(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.role == 'admin'
```

#### Security Middleware
```python
# settings/base.py
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Security settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

---

## Frontend State Management

### React Context & Hooks

#### Authentication Context
```javascript
// src/context/AuthContext.js
const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const login = async (credentials) => {
    try {
      const response = await authService.login(credentials);
      const { access, refresh } = response.data;
      
      localStorage.setItem('access_token', access);
      localStorage.setItem('refresh_token', refresh);
      
      const userData = await authService.getProfile();
      setUser(userData.data);
      
      return { success: true };
    } catch (error) {
      return { success: false, error: error.response?.data };
    }
  };

  const logout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};
```

#### API Service with Interceptors
```javascript
// src/hooks/useApi.js
export const useApi = () => {
  const { user } = useAuth();
  
  const api = axios.create({
    baseURL: process.env.REACT_APP_API_URL,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  // Request interceptor for JWT
  api.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  });

  // Response interceptor for token refresh
  api.interceptors.response.use(
    (response) => response,
    async (error) => {
      if (error.response?.status === 401) {
        const refreshToken = localStorage.getItem('refresh_token');
        if (refreshToken) {
          try {
            const response = await authService.refreshToken(refreshToken);
            localStorage.setItem('access_token', response.data.access);
            return api.request(error.config);
          } catch (refreshError) {
            // Redirect to login
            window.location.href = '/login';
          }
        }
      }
      return Promise.reject(error);
    }
  );

  return api;
};
```

---

## Deployment Architecture

### Docker Configuration

#### Backend Dockerfile
```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "project_management.wsgi:application"]
```

#### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: project_management
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: .
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@db:5432/project_management
      - REDIS_URL=redis://redis:6379
      - SECRET_KEY=${SECRET_KEY}
    depends_on:
      - db
      - redis
    ports:
      - "8000:8000"

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:
```

### CI/CD Pipeline

#### GitHub Actions Workflow
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        python manage.py test
    
    - name: Run linting
      run: |
        pip install flake8 black
        flake8 .
        black --check .

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build and push Docker images
      run: |
        docker build -t project-management-backend .
        docker build -t project-management-frontend ./frontend
    
    - name: Deploy to production
      run: |
        # Deployment commands here
```

---

## Future Extensions

### WebSocket Support

#### Django Channels Configuration
```python
# apps/notifications/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer

class TaskConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            await self.close()
            return
        
        await self.accept()
        await self.channel_layer.group_add(f"user_{self.user.id}", self.channel_name)

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(f"user_{self.user.id}", self.channel_name)

    async def task_update(self, event):
        await self.send(text_data=json.dumps({
            "type": "task_update",
            "task": event["task"]
        }))
```

#### Frontend WebSocket Service
```javascript
// src/services/notificationService.js
import io from 'socket.io-client';

class NotificationService {
  constructor() {
    this.socket = null;
    this.callbacks = [];
  }

  connect(token) {
    this.socket = io(process.env.REACT_APP_WS_URL, {
      auth: { token }
    });

    this.socket.on('task_update', (data) => {
      this.callbacks.forEach(callback => callback(data));
    });
  }

  onTaskUpdate(callback) {
    this.callbacks.push(callback);
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
    }
  }
}

export default new NotificationService();
```

### Performance Optimizations

#### Backend Optimizations
```python
# Database optimization
class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.select_related('manager').prefetch_related('members', 'tasks')
    serializer_class = ProjectSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        if self.action == 'list':
            queryset = queryset.only('id', 'title', 'status', 'manager__username')
        return queryset

# Caching
from django.core.cache import cache

class TaskService:
    @staticmethod
    def get_user_tasks(user_id):
        cache_key = f"user_tasks_{user_id}"
        tasks = cache.get(cache_key)
        
        if tasks is None:
            tasks = Task.objects.filter(assigned_to_id=user_id)
            cache.set(cache_key, tasks, timeout=300)  # 5 minutes
        
        return tasks
```

#### Frontend Optimizations
```javascript
// React Query for caching
import { useQuery, useMutation, useQueryClient } from 'react-query';

export const useProjects = () => {
  return useQuery('projects', projectService.getProjects, {
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};

export const useCreateProject = () => {
  const queryClient = useQueryClient();
  
  return useMutation(projectService.createProject, {
    onSuccess: () => {
      queryClient.invalidateQueries('projects');
    },
  });
};
```

---

## Summary

This architecture provides a comprehensive foundation for the Project Management Application with:

### Key Features
- **Scalability**: Modular design with clear separation of concerns
- **Security**: JWT authentication, role-based permissions, and security middleware
- **Performance**: Database optimization, caching, and frontend state management
- **Maintainability**: Clean folder structure and consistent patterns
- **Extensibility**: Support for future features like WebSockets and real-time updates
- **Deployment**: Docker containerization and CI/CD pipeline

### Technology Highlights
- **Backend**: Django REST Framework with service layer pattern
- **Frontend**: React with Context API and custom hooks
- **Database**: PostgreSQL with optimized queries
- **Authentication**: JWT with refresh token mechanism
- **Deployment**: Docker containers with Nginx reverse proxy
- **CI/CD**: GitHub Actions with automated testing and deployment

The system is designed to handle growth and can easily accommodate additional features like file uploads, advanced reporting, team collaboration tools, and real-time notifications. 