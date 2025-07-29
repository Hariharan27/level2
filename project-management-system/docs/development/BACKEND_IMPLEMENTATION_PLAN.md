# Backend Implementation Plan - Microservices Architecture

## Executive Summary

This plan provides a detailed roadmap for implementing the Django microservices backend based on the existing architecture documentation. The implementation will follow a phased approach, starting with core authentication and user management, then progressing to project and task management, with advanced features implemented last.

## Current Status Assessment

### ✅ Completed
- **Architecture Design**: 9 microservices with clear boundaries
- **Database Schema**: PostgreSQL schema for all services defined
- **API Design**: RESTful endpoints with standardized formats
- **Infrastructure**: Docker Compose with Kong API Gateway
- **Project Structure**: Service scaffolding completed

### ❌ Missing
- **Django Models**: No actual models implemented
- **API Views**: No Django views/endpoints implemented
- **Authentication**: No JWT implementation
- **Service Communication**: No inter-service communication
- **Testing**: No test coverage

---

## 1. Service Implementation Order

### Phase 1: Core Foundation (2-3 hours)
**Priority: CRITICAL - Start Here**

#### 1.1 Authentication Service (1-1.5 hours)
**Why First**: All other services depend on authentication
- **Dependencies**: None (foundational service)
- **Database**: `auth_db` (users, user_roles, refresh_tokens, oauth_accounts)
- **Key Features**:
  - User registration and login
  - JWT token generation/validation
  - Password reset functionality
  - Email verification

#### 1.2 User Service (1-1.5 hours)
**Why Second**: Required for user profiles and team management
- **Dependencies**: Auth Service (for user validation)
- **Database**: `user_db` (user_profiles, teams, team_members, organizations)
- **Key Features**:
  - User profile management
  - Team creation and management
  - Organization structure

### Phase 2: Core Business Logic (2-3 hours)
**Priority: HIGH**

#### 2.1 Project Service (1-1.5 hours)
**Dependencies**: User Service (for project ownership and team assignment)
- **Database**: `project_db` (projects, milestones, project_members, project_templates)
- **Key Features**:
  - Project CRUD operations
  - Milestone management
  - Project member management

#### 2.2 Task Service (1-1.5 hours)
**Dependencies**: Project Service, User Service
- **Database**: `task_db` (tasks, task_dependencies, task_templates, task_attachments)
- **Key Features**:
  - Task CRUD operations
  - Task assignment and status management
  - Task dependencies

### Phase 3: Supporting Services (1-2 hours)
**Priority: MEDIUM**

#### 3.1 Time Tracking Service (0.5-1 hour)
**Dependencies**: Task Service, User Service
- **Database**: `time_db` (time_entries, timesheets, timesheet_entries, hourly_rates)
- **Key Features**:
  - Time entry creation
  - Basic timesheet functionality

#### 3.2 Comment Service (0.5-1 hour)
**Dependencies**: Task Service, User Service
- **Database**: `comment_db` (comments, comment_reactions, comment_mentions)
- **Key Features**:
  - Comment creation and management
  - Basic threaded discussions

### Phase 4: Advanced Services (1-2 hours)
**Priority: LOW**

#### 4.1 File Service (0.5-1 hour)
**Dependencies**: Project Service, Task Service
- **Database**: `file_db` (files, file_shares, file_versions)
- **Key Features**:
  - File upload and download
  - Basic file sharing

#### 4.2 Notification Service (0.5-1 hour)
**Dependencies**: All other services
- **Database**: Redis-based (user notifications, preferences)
- **Key Features**:
  - In-app notifications
  - Basic notification preferences

#### 4.3 Analytics Service (0.5-1 hour)
**Dependencies**: All other services
- **Database**: `analytics_db` (TimescaleDB for time-series data)
- **Key Features**:
  - Basic project analytics
  - Time tracking reports

---

## 2. Django Implementation Strategy

### 2.1 Models Implementation Order

#### Authentication Service Models
```python
# apps/authentication/models.py
class User(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=100, unique=True)
    password_hash = models.CharField(max_length=255)
    first_name = models.CharField(max_length=100, null=True, blank=True)
    last_name = models.CharField(max_length=100, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    email_verified = models.BooleanField(default=False)
    last_login_at = models.DateTimeField(null=True, blank=True)
    failed_login_attempts = models.IntegerField(default=0)
    locked_until = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class UserRole(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=50)
    granted_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='granted_roles')
    granted_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class RefreshToken(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token_hash = models.CharField(max_length=255, unique=True)
    expires_at = models.DateTimeField()
    is_revoked = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
```

#### User Service Models
```python
# apps/users/models.py
class UserProfile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    user_id = models.UUIDField()  # External reference to Auth Service
    avatar_url = models.URLField(max_length=500, null=True, blank=True)
    bio = models.TextField(null=True, blank=True)
    timezone = models.CharField(max_length=50, default='UTC')
    language = models.CharField(max_length=10, default='en')
    notification_preferences = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Organization(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=255)
    domain = models.CharField(max_length=255, null=True, blank=True)
    settings = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

class Team(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    owner_id = models.UUIDField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class TeamMember(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    team = models.ForeignKey(Team, on_delete=models.CASCADE)
    user_id = models.UUIDField()
    role = models.CharField(max_length=50)
    joined_at = models.DateTimeField(auto_now_add=True)
```

### 2.2 Views/API Endpoints Implementation

#### Authentication Service Views
```python
# apps/authentication/views.py
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from .serializers import UserRegistrationSerializer, UserLoginSerializer
from .services import AuthService

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """User registration endpoint"""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = AuthService.register_user(serializer.validated_data)
        return Response({
            'success': True,
            'data': {'user': user},
            'message': 'Registration successful. Please verify your email.'
        }, status=status.HTTP_201_CREATED)
    return Response({
        'success': False,
        'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid input data',
            'details': serializer.errors
        }
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """User login endpoint"""
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        auth_data = AuthService.login_user(serializer.validated_data)
        return Response({
            'success': True,
            'data': auth_data
        }, status=status.HTTP_200_OK)
    return Response({
        'success': False,
        'error': {
            'code': 'INVALID_CREDENTIALS',
            'message': 'Invalid email or password'
        }
    }, status=status.HTTP_401_UNAUTHORIZED)
```

### 2.3 Serializers Implementation

#### Authentication Service Serializers
```python
# apps/authentication/serializers.py
from rest_framework import serializers
from .models import User

class UserRegistrationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    username = serializers.CharField(max_length=100)
    password = serializers.CharField(min_length=8, write_only=True)
    first_name = serializers.CharField(max_length=100, required=False)
    last_name = serializers.CharField(max_length=100, required=False)

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username already exists")
        return value

class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
```

### 2.4 Authentication/Authorization Setup

#### JWT Configuration
```python
# core/settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': os.getenv('JWT_SECRET'),
    'VERIFYING_KEY': None,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}
```

#### Custom Authentication Middleware
```python
# core/middleware.py
import jwt
from django.conf import settings
from rest_framework_simplejwt.exceptions import InvalidToken
from rest_framework_simplejwt.authentication import JWTAuthentication

class CustomJWTAuthentication(JWTAuthentication):
    def authenticate(self, request):
        header = self.get_header(request)
        if header is None:
            return None

        raw_token = self.get_raw_token(header)
        if raw_token is None:
            return None

        validated_token = self.get_validated_token(raw_token)
        return self.get_user(validated_token), validated_token

    def get_validated_token(self, raw_token):
        try:
            return jwt.decode(
                raw_token,
                settings.SIMPLE_JWT['SIGNING_KEY'],
                algorithms=[settings.SIMPLE_JWT['ALGORITHM']]
            )
        except jwt.ExpiredSignatureError:
            raise InvalidToken('Token has expired')
        except jwt.InvalidTokenError:
            raise InvalidToken('Token is invalid')
```

---

## 3. Core Features Implementation

### 3.1 User Registration/Login (Auth Service)

#### Registration Flow
1. **Validate input data** (email, username, password)
2. **Hash password** using bcrypt
3. **Create user record** in database
4. **Generate email verification token**
5. **Send verification email**
6. **Return success response**

#### Login Flow
1. **Validate credentials** (email, password)
2. **Check account status** (active, not locked)
3. **Generate JWT tokens** (access + refresh)
4. **Update last login timestamp**
5. **Return tokens and user data**

### 3.2 JWT Token Management

#### Token Generation
```python
# apps/authentication/services.py
import jwt
from datetime import datetime, timedelta
from django.conf import settings

class AuthService:
    @staticmethod
    def generate_tokens(user):
        access_token = jwt.encode(
            {
                'user_id': str(user.id),
                'email': user.email,
                'username': user.username,
                'roles': list(user.user_roles.values_list('role', flat=True)),
                'iat': datetime.utcnow(),
                'exp': datetime.utcnow() + timedelta(minutes=60)
            },
            settings.SIMPLE_JWT['SIGNING_KEY'],
            algorithm=settings.SIMPLE_JWT['ALGORITHM']
        )
        
        refresh_token = jwt.encode(
            {
                'user_id': str(user.id),
                'iat': datetime.utcnow(),
                'exp': datetime.utcnow() + timedelta(days=7)
            },
            settings.SIMPLE_JWT['SIGNING_KEY'],
            algorithm=settings.SIMPLE_JWT['ALGORITHM']
        )
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'expires_in': 3600,
            'user': {
                'id': str(user.id),
                'email': user.email,
                'username': user.username,
                'roles': list(user.user_roles.values_list('role', flat=True))
            }
        }
```

### 3.3 User Profile Management (User Service)

#### Profile CRUD Operations
```python
# apps/users/views.py
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    """Get user profile"""
    try:
        profile = UserProfile.objects.get(user_id=request.user.id)
        serializer = UserProfileSerializer(profile)
        return Response({
            'success': True,
            'data': serializer.data
        })
    except UserProfile.DoesNotExist:
        return Response({
            'success': False,
            'error': {
                'code': 'PROFILE_NOT_FOUND',
                'message': 'User profile not found'
            }
        }, status=status.HTTP_404_NOT_FOUND)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """Update user profile"""
    try:
        profile = UserProfile.objects.get(user_id=request.user.id)
        serializer = UserProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'success': True,
                'data': serializer.data,
                'message': 'Profile updated successfully'
            })
        return Response({
            'success': False,
            'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Invalid input data',
                'details': serializer.errors
            }
        }, status=status.HTTP_400_BAD_REQUEST)
    except UserProfile.DoesNotExist:
        return Response({
            'success': False,
            'error': {
                'code': 'PROFILE_NOT_FOUND',
                'message': 'User profile not found'
            }
        }, status=status.HTTP_404_NOT_FOUND)
```

---

## 4. Advanced Features Implementation

### 4.1 File Upload System (File Service)

#### File Upload Endpoint
```python
# apps/files/views.py
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_file(request):
    """Upload file endpoint"""
    if 'file' not in request.FILES:
        return Response({
            'success': False,
            'error': {
                'code': 'FILE_REQUIRED',
                'message': 'File is required'
            }
        }, status=status.HTTP_400_BAD_REQUEST)
    
    file_obj = request.FILES['file']
    project_id = request.data.get('project_id')
    task_id = request.data.get('task_id')
    description = request.data.get('description', '')
    
    # Validate file size and type
    if file_obj.size > 10 * 1024 * 1024:  # 10MB limit
        return Response({
            'success': False,
            'error': {
                'code': 'FILE_TOO_LARGE',
                'message': 'File size exceeds 10MB limit'
            }
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Upload to S3/MinIO
    file_url = FileService.upload_to_storage(file_obj)
    
    # Save file metadata
    file_record = File.objects.create(
        filename=file_obj.name,
        original_filename=file_obj.name,
        file_path=file_url,
        file_size=file_obj.size,
        mime_type=file_obj.content_type,
        uploaded_by=request.user.id,
        project_id=project_id,
        task_id=task_id
    )
    
    return Response({
        'success': True,
        'data': {
            'id': str(file_record.id),
            'filename': file_record.filename,
            'file_size': file_record.file_size,
            'url': file_record.file_path,
            'uploaded_by': file_record.uploaded_by
        }
    }, status=status.HTTP_201_CREATED)
```

### 4.2 Comment System (Comment Service)

#### Comment Creation
```python
# apps/comments/views.py
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_comment(request):
    """Create comment endpoint"""
    serializer = CommentSerializer(data=request.data)
    if serializer.is_valid():
        comment = serializer.save(author_id=request.user.id)
        
        # Process mentions
        mentions = CommentService.extract_mentions(serializer.validated_data['content'])
        for user_id in mentions:
            CommentMention.objects.create(
                comment=comment,
                mentioned_user_id=user_id
            )
        
        # Send notifications
        NotificationService.notify_mentions(comment, mentions)
        
        return Response({
            'success': True,
            'data': CommentSerializer(comment).data
        }, status=status.HTTP_201_CREATED)
    
    return Response({
        'success': False,
        'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid input data',
            'details': serializer.errors
        }
    }, status=status.HTTP_400_BAD_REQUEST)
```

---

## 5. Testing Strategy

### 5.1 Unit Tests for Models

#### Authentication Service Tests
```python
# apps/authentication/tests.py
from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import User, UserRole, RefreshToken

class UserModelTest(TestCase):
    def setUp(self):
        self.user_data = {
            'email': 'test@example.com',
            'username': 'testuser',
            'password_hash': 'hashed_password',
            'first_name': 'Test',
            'last_name': 'User'
        }
    
    def test_create_user(self):
        user = User.objects.create(**self.user_data)
        self.assertEqual(user.email, 'test@example.com')
        self.assertEqual(user.username, 'testuser')
        self.assertTrue(user.is_active)
        self.assertFalse(user.email_verified)
    
    def test_user_str_representation(self):
        user = User.objects.create(**self.user_data)
        self.assertEqual(str(user), 'testuser (test@example.com)')

class UserRoleModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            email='test@example.com',
            username='testuser',
            password_hash='hashed_password'
        )
    
    def test_create_user_role(self):
        role = UserRole.objects.create(
            user=self.user,
            role='admin'
        )
        self.assertEqual(role.role, 'admin')
        self.assertEqual(role.user, self.user)
```

### 5.2 API Endpoint Tests

#### Authentication API Tests
```python
# apps/authentication/tests.py
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from .models import User

class AuthenticationAPITest(APITestCase):
    def setUp(self):
        self.register_url = reverse('auth:register')
        self.login_url = reverse('auth:login')
        self.user_data = {
            'email': 'test@example.com',
            'username': 'testuser',
            'password': 'SecurePassword123!',
            'first_name': 'Test',
            'last_name': 'User'
        }
    
    def test_user_registration(self):
        response = self.client.post(self.register_url, self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertIn('user', response.data['data'])
        
        # Verify user was created
        user = User.objects.get(email='test@example.com')
        self.assertEqual(user.username, 'testuser')
    
    def test_user_login(self):
        # Create user first
        User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='SecurePassword123!'
        )
        
        login_data = {
            'email': 'test@example.com',
            'password': 'SecurePassword123!'
        }
        
        response = self.client.post(self.login_url, login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('access_token', response.data['data'])
        self.assertIn('refresh_token', response.data['data'])
```

### 5.3 Integration Tests

#### Service-to-Service Communication Tests
```python
# tests/integration/test_service_communication.py
import pytest
from django.test import TestCase
from unittest.mock import patch
from apps.tasks.services import TaskService
from apps.users.services import UserService

class ServiceCommunicationTest(TestCase):
    @patch('apps.tasks.services.UserService.get_user')
    def test_task_with_user_details(self, mock_get_user):
        # Mock user service response
        mock_get_user.return_value = {
            'id': 'user-123',
            'name': 'John Doe',
            'email': 'john@example.com'
        }
        
        # Test task service fetching user details
        task_with_user = TaskService.get_task_with_user('task-123', 'token')
        
        self.assertIn('assigned_to', task_with_user)
        self.assertEqual(task_with_user['assigned_to']['name'], 'John Doe')
        mock_get_user.assert_called_once_with('user-123', 'token')
```

---

## 6. Security Implementation

### 6.1 JWT Token Validation

#### Token Validation Middleware
```python
# core/middleware.py
import jwt
from django.conf import settings
from rest_framework_simplejwt.exceptions import InvalidToken
from rest_framework.response import Response
from rest_framework import status

class JWTAuthMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Skip authentication for certain endpoints
        if request.path.startswith('/api/v1/auth/login') or \
           request.path.startswith('/api/v1/auth/register'):
            return self.get_response(request)
        
        # Extract token from Authorization header
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return Response({
                'success': False,
                'error': {
                    'code': 'AUTHENTICATION_FAILED',
                    'message': 'Authorization header required'
                }
            }, status=status.HTTP_401_UNAUTHORIZED)
        
        token = auth_header.split(' ')[1]
        
        try:
            # Validate token
            payload = jwt.decode(
                token,
                settings.SIMPLE_JWT['SIGNING_KEY'],
                algorithms=[settings.SIMPLE_JWT['ALGORITHM']]
            )
            
            # Add user info to request
            request.user_id = payload['user_id']
            request.user_roles = payload.get('roles', [])
            
        except jwt.ExpiredSignatureError:
            return Response({
                'success': False,
                'error': {
                    'code': 'TOKEN_EXPIRED',
                    'message': 'Token has expired'
                }
            }, status=status.HTTP_401_UNAUTHORIZED)
        except jwt.InvalidTokenError:
            return Response({
                'success': False,
                'error': {
                    'code': 'INVALID_TOKEN',
                    'message': 'Invalid token'
                }
            }, status=status.HTTP_401_UNAUTHORIZED)
        
        return self.get_response(request)
```

### 6.2 Role-Based Access Control

#### Permission Decorators
```python
# core/permissions.py
from functools import wraps
from rest_framework.response import Response
from rest_framework import status

def require_role(role):
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            if role not in request.user_roles:
                return Response({
                    'success': False,
                    'error': {
                        'code': 'AUTHORIZATION_FAILED',
                        'message': f'Role {role} required'
                    }
                }, status=status.HTTP_403_FORBIDDEN)
            return view_func(request, *args, **kwargs)
        return wrapper
    return decorator

def require_permission(permission):
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            # Check if user has required permission
            user_permissions = get_user_permissions(request.user_id)
            if permission not in user_permissions:
                return Response({
                    'success': False,
                    'error': {
                        'code': 'AUTHORIZATION_FAILED',
                        'message': f'Permission {permission} required'
                    }
                }, status=status.HTTP_403_FORBIDDEN)
            return view_func(request, *args, **kwargs)
        return wrapper
    return decorator
```

### 6.3 Input Validation and Sanitization

#### Validation Middleware
```python
# core/validation.py
import re
from django.core.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework import status

class InputValidationMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.method in ['POST', 'PUT', 'PATCH']:
            # Validate and sanitize input
            try:
                self.validate_input(request.data)
            except ValidationError as e:
                return Response({
                    'success': False,
                    'error': {
                        'code': 'VALIDATION_ERROR',
                        'message': str(e)
                    }
                }, status=status.HTTP_400_BAD_REQUEST)
        
        return self.get_response(request)
    
    def validate_input(self, data):
        # Email validation
        if 'email' in data:
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, data['email']):
                raise ValidationError('Invalid email format')
        
        # SQL injection prevention
        sql_keywords = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE']
        for key, value in data.items():
            if isinstance(value, str):
                for keyword in sql_keywords:
                    if keyword.lower() in value.lower():
                        raise ValidationError(f'Invalid input detected in {key}')
```

### 6.4 Rate Limiting

#### Rate Limiting Configuration
```python
# core/settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour',
        'auth': '10/minute',  # Stricter for auth endpoints
    }
}

# Custom rate limiting for auth endpoints
class AuthRateThrottle(UserRateThrottle):
    rate = '10/minute'
    scope = 'auth'
```

---

## 7. Time Estimates and Risk Assessment

### 7.1 Time Estimates

| Phase | Service | Estimated Time | Priority |
|-------|---------|----------------|----------|
| 1 | Auth Service | 1-1.5 hours | CRITICAL |
| 1 | User Service | 1-1.5 hours | CRITICAL |
| 2 | Project Service | 1-1.5 hours | HIGH |
| 2 | Task Service | 1-1.5 hours | HIGH |
| 3 | Time Service | 0.5-1 hour | MEDIUM |
| 3 | Comment Service | 0.5-1 hour | MEDIUM |
| 4 | File Service | 0.5-1 hour | LOW |
| 4 | Notification Service | 0.5-1 hour | LOW |
| 4 | Analytics Service | 0.5-1 hour | LOW |
| **Total** | **All Services** | **6-10 hours** | **-** |

### 7.2 Risk Assessment

#### High-Risk Items
1. **Service Dependencies**: If Auth Service fails, all other services fail
   - **Mitigation**: Implement circuit breakers and fallback mechanisms
   
2. **Database Migrations**: Complex migrations across multiple databases
   - **Mitigation**: Test migrations thoroughly in staging environment
   
3. **JWT Token Security**: Token compromise could affect entire system
   - **Mitigation**: Implement token rotation and short expiration times

#### Medium-Risk Items
1. **Service Communication**: Network failures between services
   - **Mitigation**: Implement retry mechanisms and timeout handling
   
2. **Data Consistency**: Maintaining consistency across services
   - **Mitigation**: Use event-driven architecture for eventual consistency

#### Low-Risk Items
1. **File Upload**: Large file handling and storage
   - **Mitigation**: Implement file size limits and virus scanning
   
2. **Performance**: Slow response times with multiple service calls
   - **Mitigation**: Implement caching and async processing

### 7.3 Success Criteria

#### Phase 1 Success Criteria
- [ ] User can register and login successfully
- [ ] JWT tokens are generated and validated correctly
- [ ] User profiles can be created and updated
- [ ] Teams can be created and managed

#### Phase 2 Success Criteria
- [ ] Projects can be created, updated, and deleted
- [ ] Tasks can be created, assigned, and status updated
- [ ] Project and task relationships work correctly

#### Phase 3 Success Criteria
- [ ] Time entries can be created and tracked
- [ ] Comments can be added to tasks and projects
- [ ] Basic notifications are sent

#### Phase 4 Success Criteria
- [ ] Files can be uploaded and downloaded
- [ ] Real-time notifications work
- [ ] Basic analytics are generated

---

## 8. Implementation Checklist

### Phase 1: Core Foundation
- [ ] Set up Auth Service models and migrations
- [ ] Implement user registration and login endpoints
- [ ] Set up JWT token generation and validation
- [ ] Create User Service models and migrations
- [ ] Implement user profile management endpoints
- [ ] Set up team and organization management
- [ ] Write unit tests for Auth and User services
- [ ] Test service-to-service communication

### Phase 2: Core Business Logic
- [ ] Set up Project Service models and migrations
- [ ] Implement project CRUD endpoints
- [ ] Create milestone management functionality
- [ ] Set up Task Service models and migrations
- [ ] Implement task CRUD endpoints
- [ ] Add task assignment and status management
- [ ] Write integration tests for Project and Task services
- [ ] Test cross-service data flow

### Phase 3: Supporting Services
- [ ] Set up Time Service models and migrations
- [ ] Implement time entry creation and tracking
- [ ] Set up Comment Service models and migrations
- [ ] Implement comment creation and management
- [ ] Add mention functionality to comments
- [ ] Write tests for Time and Comment services

### Phase 4: Advanced Services
- [ ] Set up File Service models and migrations
- [ ] Implement file upload and download functionality
- [ ] Set up Notification Service (Redis-based)
- [ ] Implement in-app notifications
- [ ] Set up Analytics Service models and migrations
- [ ] Implement basic project analytics
- [ ] Write end-to-end tests for all services

### Security and Performance
- [ ] Implement rate limiting for all endpoints
- [ ] Add input validation and sanitization
- [ ] Set up monitoring and logging
- [ ] Implement error handling and recovery
- [ ] Add performance optimization (caching, indexing)
- [ ] Conduct security testing and penetration testing

---

## 9. Next Steps

1. **Start with Auth Service**: Implement user registration and login
2. **Set up JWT authentication**: Configure token generation and validation
3. **Create User Service**: Implement user profile management
4. **Build Project Service**: Add project management functionality
5. **Develop Task Service**: Implement task management features
6. **Add supporting services**: Time tracking and comments
7. **Implement advanced features**: File uploads and notifications
8. **Add analytics**: Basic reporting and metrics
9. **Test thoroughly**: Unit, integration, and end-to-end tests
10. **Deploy and monitor**: Production deployment with monitoring

This implementation plan provides a clear roadmap for building the microservices backend based on your existing architecture documentation. The phased approach ensures that core functionality is implemented first, with advanced features added incrementally. 