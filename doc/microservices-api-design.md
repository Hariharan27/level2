# Microservices API Design & Data Flow

## Table of Contents
1. [Overview](#overview)
2. [API Standards](#api-standards)
3. [Service Endpoints](#service-endpoints)
4. [Data Flow Patterns](#data-flow-patterns)
5. [Error Handling](#error-handling)
6. [Authentication & Authorization](#authentication--authorization)
7. [Rate Limiting & Pagination](#rate-limiting--pagination)

---

## Overview

This document defines the RESTful API design for the microservices architecture, including endpoint specifications, data flow patterns, and cross-service communication strategies.

### **API Design Principles:**
- **RESTful Design**: Follow REST conventions with proper HTTP methods
- **Service Autonomy**: Each service exposes its own API
- **Consistent Patterns**: Standardized request/response formats
- **Security First**: JWT-based authentication with role-based authorization
- **Performance**: Pagination, filtering, and caching strategies

---

## API Standards

### **Base URL Structure**
```
https://api-gateway.example.com/api/v1/{service-name}/{resource}
```

### **Standard Response Format**
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456789"
}
```

### **Error Response Format**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456789"
}
```

### **Pagination Format**
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

---

## Service Endpoints

### 1. Authentication Service

#### **User Registration**
```http
POST /api/v1/auth/register
Content-Type: application/json
```

**Request:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePassword123!",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "username": "johndoe",
      "first_name": "John",
      "last_name": "Doe",
      "email_verified": false
    },
    "message": "Registration successful. Please verify your email."
  }
}
```

#### **User Login**
```http
POST /api/v1/auth/login
Content-Type: application/json
```

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "username": "johndoe",
      "roles": ["user"],
      "permissions": ["read:projects", "write:tasks"]
    }
  }
}
```

#### **Token Refresh**
```http
POST /api/v1/auth/refresh
Authorization: Bearer {refresh_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

#### **Password Reset Request**
```http
POST /api/v1/auth/forgot-password
Content-Type: application/json
```

**Request:**
```json
{
  "email": "user@example.com"
}
```

#### **Password Reset**
```http
POST /api/v1/auth/reset-password
Content-Type: application/json
```

**Request:**
```json
{
  "token": "reset_token_here",
  "new_password": "NewSecurePassword123!"
}
```

### 2. User Service

#### **Get User Profile**
```http
GET /api/v1/users/profile
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "johndoe",
    "first_name": "John",
    "last_name": "Doe",
    "avatar_url": "https://example.com/avatars/john.jpg",
    "bio": "Senior Developer",
    "timezone": "UTC",
    "language": "en",
    "notification_preferences": {
      "email": true,
      "push": false,
      "in_app": true
    }
  }
}
```

#### **Update User Profile**
```http
PUT /api/v1/users/profile
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "first_name": "John",
  "last_name": "Smith",
  "bio": "Full Stack Developer",
  "timezone": "America/New_York",
  "notification_preferences": {
    "email": true,
    "push": true,
    "in_app": true
  }
}
```

#### **Get Organizations**
```http
GET /api/v1/organizations
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "org-123",
      "name": "Acme Corp",
      "domain": "acme.com",
      "description": "Software Development Company",
      "logo_url": "https://example.com/logos/acme.png",
      "subscription_plan": "premium",
      "role": "admin"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 1,
    "total_pages": 1
  }
}
```

#### **Create Organization**
```http
POST /api/v1/organizations
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "name": "New Organization",
  "domain": "neworg.com",
  "description": "A new organization"
}
```

#### **Get Teams**
```http
GET /api/v1/teams?organization_id={org_id}
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "team-123",
      "name": "Development Team",
      "description": "Core development team",
      "organization_id": "org-123",
      "owner_id": "user-123",
      "member_count": 5,
      "role": "admin"
    }
  ]
}
```

#### **Invite User to Organization**
```http
POST /api/v1/organizations/{org_id}/invitations
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "email": "newuser@example.com",
  "role": "member"
}
```

### 3. Project Service

#### **Get Projects**
```http
GET /api/v1/projects?organization_id={org_id}&status=active&page=1&per_page=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "proj-123",
      "name": "E-commerce Platform",
      "description": "Modern e-commerce solution",
      "status": "active",
      "start_date": "2024-01-01",
      "end_date": "2024-06-30",
      "owner_id": "user-123",
      "organization_id": "org-123",
      "team_id": "team-123",
      "progress": 65,
      "total_tasks": 50,
      "completed_tasks": 32,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 15,
    "total_pages": 1
  }
}
```

#### **Create Project**
```http
POST /api/v1/projects
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "name": "New Project",
  "description": "Project description",
  "start_date": "2024-02-01",
  "end_date": "2024-08-31",
  "organization_id": "org-123",
  "team_id": "team-123",
  "settings": {
    "time_tracking": true,
    "file_attachments": true
  }
}
```

#### **Get Project Details**
```http
GET /api/v1/projects/{project_id}
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "proj-123",
    "name": "E-commerce Platform",
    "description": "Modern e-commerce solution",
    "status": "active",
    "start_date": "2024-01-01",
    "end_date": "2024-06-30",
    "owner_id": "user-123",
    "organization_id": "org-123",
    "team_id": "team-123",
    "progress": 65,
    "total_tasks": 50,
    "completed_tasks": 32,
    "total_hours": 120.5,
    "billable_hours": 95.2,
    "members": [
      {
        "id": "user-123",
        "name": "John Doe",
        "role": "owner",
        "avatar_url": "https://example.com/avatars/john.jpg"
      }
    ],
    "milestones": [
      {
        "id": "milestone-123",
        "title": "MVP Release",
        "due_date": "2024-03-15",
        "status": "in_progress"
      }
    ],
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

#### **Update Project**
```http
PUT /api/v1/projects/{project_id}
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "name": "Updated Project Name",
  "description": "Updated description",
  "status": "on_hold",
  "end_date": "2024-09-30"
}
```

#### **Get Project Milestones**
```http
GET /api/v1/projects/{project_id}/milestones
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "milestone-123",
      "title": "MVP Release",
      "description": "Minimum viable product release",
      "due_date": "2024-03-15",
      "status": "in_progress",
      "completed_at": null,
      "created_by": "user-123",
      "task_count": 15,
      "completed_task_count": 8
    }
  ]
}
```

#### **Create Milestone**
```http
POST /api/v1/projects/{project_id}/milestones
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "title": "Beta Release",
  "description": "Beta version release",
  "due_date": "2024-05-15"
}
```

### 4. Task Service

#### **Get Tasks**
```http
GET /api/v1/tasks?project_id={project_id}&status=todo&assignee_id={user_id}&page=1&per_page=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "task-123",
      "title": "Implement User Authentication",
      "description": "Add JWT-based authentication system",
      "project_id": "proj-123",
      "assigned_to": {
        "id": "user-123",
        "name": "John Doe",
        "avatar_url": "https://example.com/avatars/john.jpg"
      },
      "created_by": {
        "id": "user-456",
        "name": "Jane Smith",
        "avatar_url": "https://example.com/avatars/jane.jpg"
      },
      "status": "in_progress",
      "priority": "high",
      "due_date": "2024-02-15T00:00:00Z",
      "estimated_hours": 8.0,
      "actual_hours": 4.5,
      "tags": ["backend", "security"],
      "comment_count": 5,
      "attachment_count": 2,
      "created_at": "2024-01-15T00:00:00Z",
      "updated_at": "2024-01-16T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

#### **Create Task**
```http
POST /api/v1/tasks
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "title": "New Task",
  "description": "Task description",
  "project_id": "proj-123",
  "assigned_to": "user-123",
  "priority": "medium",
  "due_date": "2024-02-20T00:00:00Z",
  "estimated_hours": 6.0,
  "tags": ["frontend", "ui"]
}
```

#### **Get Task Details**
```http
GET /api/v1/tasks/{task_id}
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "task-123",
    "title": "Implement User Authentication",
    "description": "Add JWT-based authentication system",
    "project_id": "proj-123",
    "assigned_to": {
      "id": "user-123",
      "name": "John Doe",
      "avatar_url": "https://example.com/avatars/john.jpg"
    },
    "created_by": {
      "id": "user-456",
      "name": "Jane Smith",
      "avatar_url": "https://example.com/avatars/jane.jpg"
    },
    "status": "in_progress",
    "priority": "high",
    "due_date": "2024-02-15T00:00:00Z",
    "estimated_hours": 8.0,
    "actual_hours": 4.5,
    "tags": ["backend", "security"],
    "dependencies": [
      {
        "id": "task-456",
        "title": "Database Schema Design",
        "status": "done"
      }
    ],
    "attachments": [
      {
        "id": "file-123",
        "filename": "auth-design.pdf",
        "file_size": 1024000,
        "uploaded_by": "user-456"
      }
    ],
    "time_entries": [
      {
        "id": "time-123",
        "duration_minutes": 120,
        "description": "Initial setup",
        "date": "2024-01-16"
      }
    ],
    "created_at": "2024-01-15T00:00:00Z",
    "updated_at": "2024-01-16T10:30:00Z"
  }
}
```

#### **Update Task Status**
```http
PUT /api/v1/tasks/{task_id}/status
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "status": "review"
}
```

#### **Assign Task**
```http
PUT /api/v1/tasks/{task_id}/assign
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "assigned_to": "user-789"
}
```

#### **Get Task Dependencies**
```http
GET /api/v1/tasks/{task_id}/dependencies
Authorization: Bearer {access_token}
```

#### **Add Task Dependency**
```http
POST /api/v1/tasks/{task_id}/dependencies
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "depends_on_task_id": "task-456",
  "dependency_type": "finish_to_start"
}
```

### 5. Comment Service

#### **Get Comments**
```http
GET /api/v1/comments?entity_type=task&entity_id={task_id}&page=1&per_page=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "comment-123",
      "content": "This looks good! Ready for review.",
      "author": {
        "id": "user-123",
        "name": "John Doe",
        "avatar_url": "https://example.com/avatars/john.jpg"
      },
      "entity_type": "task",
      "entity_id": "task-123",
      "parent_comment_id": null,
      "is_edited": false,
      "reactions": [
        {
          "type": "thumbs_up",
          "count": 3,
          "users": ["user-123", "user-456", "user-789"]
        }
      ],
      "mentions": [
        {
          "id": "user-456",
          "name": "Jane Smith"
        }
      ],
      "created_at": "2024-01-16T10:30:00Z",
      "updated_at": "2024-01-16T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 15,
    "total_pages": 1
  }
}
```

#### **Create Comment**
```http
POST /api/v1/comments
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "content": "Great work on this feature! @jane.smith can you review the UI changes?",
  "entity_type": "task",
  "entity_id": "task-123",
  "parent_comment_id": null
}
```

#### **Update Comment**
```http
PUT /api/v1/comments/{comment_id}
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "content": "Updated comment content"
}
```

#### **Add Comment Reaction**
```http
POST /api/v1/comments/{comment_id}/reactions
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "reaction_type": "thumbs_up"
}
```

### 6. Time Tracking Service

#### **Get Time Entries**
```http
GET /api/v1/time-entries?user_id={user_id}&project_id={project_id}&start_date=2024-01-01&end_date=2024-01-31&page=1&per_page=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "time-123",
      "user_id": "user-123",
      "task": {
        "id": "task-123",
        "title": "Implement User Authentication"
      },
      "project": {
        "id": "proj-123",
        "name": "E-commerce Platform"
      },
      "description": "Implemented JWT token generation",
      "start_time": "2024-01-16T09:00:00Z",
      "end_time": "2024-01-16T11:30:00Z",
      "duration_minutes": 150,
      "billable": true,
      "hourly_rate": 75.00,
      "currency": "USD",
      "status": "completed",
      "created_at": "2024-01-16T09:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

#### **Start Time Entry**
```http
POST /api/v1/time-entries/start
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "task_id": "task-123",
  "description": "Working on authentication system"
}
```

#### **Stop Time Entry**
```http
PUT /api/v1/time-entries/{time_entry_id}/stop
Authorization: Bearer {access_token}
```

#### **Create Time Entry**
```http
POST /api/v1/time-entries
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "task_id": "task-123",
  "project_id": "proj-123",
  "description": "Code review and testing",
  "start_time": "2024-01-16T14:00:00Z",
  "end_time": "2024-01-16T16:00:00Z",
  "billable": true,
  "hourly_rate": 75.00
}
```

#### **Get Timesheets**
```http
GET /api/v1/timesheets?user_id={user_id}&week_start_date=2024-01-15&page=1&per_page=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "timesheet-123",
      "user_id": "user-123",
      "week_start_date": "2024-01-15",
      "total_hours": 40.5,
      "billable_hours": 38.0,
      "status": "submitted",
      "submitted_at": "2024-01-19T17:00:00Z",
      "approved_by": "user-456",
      "approved_at": "2024-01-20T09:00:00Z",
      "entries": [
        {
          "id": "time-123",
          "description": "Task A",
          "duration_minutes": 240,
          "billable": true
        }
      ]
    }
  ]
}
```

#### **Submit Timesheet**
```http
PUT /api/v1/timesheets/{timesheet_id}/submit
Authorization: Bearer {access_token}
```

#### **Approve Timesheet**
```http
PUT /api/v1/timesheets/{timesheet_id}/approve
Authorization: Bearer {access_token}
```

### 7. File Service

#### **Upload File**
```http
POST /api/v1/files/upload
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**Request:**
```
file: [binary file data]
project_id: proj-123
task_id: task-123
description: Design mockup
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "file-123",
    "filename": "design-mockup.png",
    "original_filename": "mockup_v1.png",
    "file_size": 2048000,
    "mime_type": "image/png",
    "url": "https://storage.example.com/files/file-123",
    "uploaded_by": "user-123",
    "project_id": "proj-123",
    "task_id": "task-123",
    "created_at": "2024-01-16T10:30:00Z"
  }
}
```

#### **Get File Details**
```http
GET /api/v1/files/{file_id}
Authorization: Bearer {access_token}
```

#### **Download File**
```http
GET /api/v1/files/{file_id}/download
Authorization: Bearer {access_token}
```

#### **Share File**
```http
PUT /api/v1/files/{file_id}/share
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "shared_with": ["user-456", "user-789"],
  "permission": "read",
  "expires_at": "2024-02-16T00:00:00Z"
}
```

### 8. Notification Service

#### **Get Notifications**
```http
GET /api/v1/notifications?page=1&per_page=20&unread_only=true
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "notif-123",
      "type": "task_assigned",
      "title": "Task Assigned",
      "message": "You have been assigned to 'Implement User Authentication'",
      "data": {
        "task_id": "task-123",
        "task_title": "Implement User Authentication",
        "project_id": "proj-123",
        "project_name": "E-commerce Platform"
      },
      "read": false,
      "created_at": "2024-01-16T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 15,
    "total_pages": 1
  }
}
```

#### **Mark Notification as Read**
```http
PUT /api/v1/notifications/{notification_id}/read
Authorization: Bearer {access_token}
```

#### **Get Notification Preferences**
```http
GET /api/v1/notifications/preferences
Authorization: Bearer {access_token}
```

#### **Update Notification Preferences**
```http
PUT /api/v1/notifications/preferences
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request:**
```json
{
  "email": {
    "task_assigned": true,
    "project_updates": false,
    "mentions": true
  },
  "push": {
    "task_assigned": true,
    "project_updates": true,
    "mentions": true
  },
  "in_app": {
    "task_assigned": true,
    "project_updates": true,
    "mentions": true
  }
}
```

### 9. Analytics Service

#### **Get Project Analytics**
```http
GET /api/v1/analytics/projects/{project_id}?start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "project_id": "proj-123",
    "period": {
      "start_date": "2024-01-01",
      "end_date": "2024-01-31"
    },
    "tasks": {
      "total": 50,
      "completed": 32,
      "in_progress": 12,
      "todo": 6,
      "completion_rate": 64.0
    },
    "time_tracking": {
      "total_hours": 240.5,
      "billable_hours": 195.2,
      "average_hours_per_day": 8.0,
      "most_active_day": "2024-01-15"
    },
    "team_performance": {
      "members": [
        {
          "user_id": "user-123",
          "name": "John Doe",
          "tasks_completed": 15,
          "hours_logged": 80.5,
          "productivity_score": 85.2
        }
      ]
    },
    "trends": {
      "daily_completion_rate": [
        {"date": "2024-01-01", "rate": 60.0},
        {"date": "2024-01-02", "rate": 65.0}
      ]
    }
  }
}
```

#### **Get User Analytics**
```http
GET /api/v1/analytics/users/{user_id}?start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer {access_token}
```

#### **Get Time Analytics**
```http
GET /api/v1/analytics/time-tracking?user_id={user_id}&project_id={project_id}&start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer {access_token}
```

---

## Data Flow Patterns

### **1. Service-to-Service Communication**

#### **Synchronous Communication (REST)**
```mermaid
graph LR
    A[API Gateway] --> B[Task Service]
    B --> C[User Service]
    B --> D[Project Service]
    C --> E[Auth Service]
```

**Example: Task Service fetching user details**
```python
# Task Service - Get task with user details
async def get_task_with_user(task_id: str, user_token: str):
    # Get task from local database
    task = await task_repository.get_by_id(task_id)
    
    # Fetch user details from User Service
    user_response = await user_service_client.get_user(
        user_id=task.assigned_to,
        token=user_token
    )
    
    # Fetch project details from Project Service
    project_response = await project_service_client.get_project(
        project_id=task.project_id,
        token=user_token
    )
    
    return {
        **task.dict(),
        "assigned_to": user_response.data,
        "project": project_response.data
    }
```

#### **Asynchronous Communication (Event-Driven)**
```mermaid
graph LR
    A[Task Service] --> B[Event Bus]
    B --> C[Notification Service]
    B --> D[Analytics Service]
    B --> E[Time Tracking Service]
```

**Example: Task assignment event**
```python
# Task Service - Publish task assigned event
async def assign_task(task_id: str, user_id: str):
    # Update task in database
    task = await task_repository.assign_task(task_id, user_id)
    
    # Publish event
    await event_bus.publish("task.assigned", {
        "task_id": task_id,
        "assigned_to": user_id,
        "assigned_by": current_user.id,
        "project_id": task.project_id,
        "timestamp": datetime.utcnow().isoformat()
    })
    
    return task

# Notification Service - Handle task assigned event
async def handle_task_assigned(event_data: dict):
    notification = await notification_service.create_notification(
        user_id=event_data["assigned_to"],
        type="task_assigned",
        title="Task Assigned",
        message=f"You have been assigned to a new task",
        data=event_data
    )
    
    # Send real-time notification via WebSocket
    await websocket_manager.send_to_user(
        user_id=event_data["assigned_to"],
        notification=notification
    )
```

### **2. Data Aggregation Patterns**

#### **API Gateway Aggregation**
```python
# API Gateway - Aggregate data from multiple services
async def get_project_dashboard(project_id: str, user_token: str):
    # Parallel requests to multiple services
    project_future = project_service.get_project(project_id, user_token)
    tasks_future = task_service.get_project_tasks(project_id, user_token)
    time_future = time_service.get_project_time(project_id, user_token)
    comments_future = comment_service.get_project_comments(project_id, user_token)
    
    # Wait for all responses
    project, tasks, time_data, comments = await asyncio.gather(
        project_future, tasks_future, time_future, comments_future
    )
    
    return {
        "project": project.data,
        "tasks": tasks.data,
        "time_tracking": time_data.data,
        "recent_comments": comments.data
    }
```

#### **Service-Level Aggregation**
```python
# Project Service - Aggregate project statistics
async def get_project_statistics(project_id: str):
    # Get local project data
    project = await project_repository.get_by_id(project_id)
    
    # Query Task Service for task statistics
    task_stats = await task_service_client.get_project_task_stats(project_id)
    
    # Query Time Service for time statistics
    time_stats = await time_service_client.get_project_time_stats(project_id)
    
    # Query Comment Service for comment statistics
    comment_stats = await comment_service_client.get_project_comment_stats(project_id)
    
    return {
        "project": project,
        "task_statistics": task_stats,
        "time_statistics": time_stats,
        "comment_statistics": comment_stats
    }
```

### **3. Caching Strategies**

#### **Service-Level Caching**
```python
# User Service - Cache user profiles
async def get_user_profile(user_id: str):
    # Check cache first
    cached_profile = await cache.get(f"user_profile:{user_id}")
    if cached_profile:
        return cached_profile
    
    # Fetch from database
    profile = await user_repository.get_profile(user_id)
    
    # Cache for 1 hour
    await cache.set(f"user_profile:{user_id}", profile, ttl=3600)
    
    return profile
```

#### **API Gateway Caching**
```python
# API Gateway - Cache aggregated responses
async def get_project_dashboard_cached(project_id: str, user_token: str):
    cache_key = f"project_dashboard:{project_id}:{user_id}"
    
    # Check cache
    cached_dashboard = await cache.get(cache_key)
    if cached_dashboard:
        return cached_dashboard
    
    # Fetch fresh data
    dashboard = await get_project_dashboard(project_id, user_token)
    
    # Cache for 5 minutes
    await cache.set(cache_key, dashboard, ttl=300)
    
    return dashboard
```

---

## Error Handling

### **Standard Error Response Format**

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      {
        "field": "field_name",
        "message": "Field-specific error message"
      }
    ]
  },
  "timestamp": "2024-01-16T10:30:00Z",
  "request_id": "req_123456789"
}
```

### **Error Codes Table**

| Error Code | HTTP Status | Description | Example |
|------------|-------------|-------------|---------|
| `VALIDATION_ERROR` | 400 | Input validation failed | Missing required fields |
| `AUTHENTICATION_FAILED` | 401 | Invalid or missing authentication | Expired JWT token |
| `AUTHORIZATION_FAILED` | 403 | Insufficient permissions | User cannot access resource |
| `RESOURCE_NOT_FOUND` | 404 | Requested resource not found | Project ID doesn't exist |
| `RESOURCE_CONFLICT` | 409 | Resource conflict | Email already exists |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests | API rate limit exceeded |
| `INTERNAL_SERVER_ERROR` | 500 | Internal server error | Database connection failed |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable | Downstream service down |

### **Service-Specific Error Handling**

#### **Authentication Service Errors**
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password",
    "details": []
  }
}
```

#### **Validation Errors**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email must be a valid email address"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters long"
      }
    ]
  }
}
```

#### **Cross-Service Communication Errors**
```json
{
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "User service is temporarily unavailable",
    "details": [
      {
        "service": "user-service",
        "status": "down",
        "retry_after": 30
      }
    ]
  }
}
```

---

## Authentication & Authorization

### **JWT Token Structure**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "username": "johndoe",
  "roles": ["user", "admin"],
  "permissions": [
    "read:projects",
    "write:projects",
    "read:tasks",
    "write:tasks",
    "delete:projects"
  ],
  "organization_id": "org-123",
  "team_id": "team-123",
  "iat": 1640995200,
  "exp": 1641081600,
  "jti": "unique_token_id"
}
```

### **Authorization Headers**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Service-Token: service_internal_token_for_service_to_service_calls
```

### **Permission-Based Authorization**
```python
# Permission decorator example
def require_permission(permission: str):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            user_permissions = get_user_permissions_from_token()
            if permission not in user_permissions:
                raise AuthorizationError("Insufficient permissions")
            return await func(*args, **kwargs)
        return wrapper
    return decorator

# Usage
@require_permission("write:projects")
async def create_project(project_data: dict):
    # Project creation logic
    pass
```

---

## Rate Limiting & Pagination

### **Rate Limiting Headers**
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

### **Pagination Parameters**
```http
GET /api/v1/projects?page=1&per_page=20&sort_by=created_at&sort_order=desc
```

### **Pagination Response**
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false,
    "next_page": 2,
    "prev_page": null
  }
}
```

### **Filtering & Sorting**
```http
GET /api/v1/tasks?status=in_progress&priority=high&assignee_id=user-123&due_date_gte=2024-01-01&sort_by=due_date&sort_order=asc
```

### **Search Parameters**
```http
GET /api/v1/tasks?search=authentication&search_fields=title,description
```

This comprehensive API design provides a solid foundation for your microservices architecture with clear service boundaries, proper error handling, and scalable communication patterns. 