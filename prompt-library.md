# Prompt Library

## Project Management Application Architecture Design

### Original Prompt
```
You are an expert full-stack software architect.

I am building a Project Management Application using the following tech stack:

Backend: Python with Django & Django REST Framework

Frontend: React.js (Single Page Application)

Database: PostgreSQL

Authentication: JWT (via djangorestframework-simplejwt)

The application must support the following features:

User Authentication (Login, Signup, Logout)

Role-based Access Control (Admin, Manager, Developer)

Project Management (Create, view, update, delete projects)

Task Management (CRUD tasks, assign users, status, due dates)

Task Comments (Add/view comments per task, with timestamps)

Your task:

Design a scalable, modular system architecture using industry best practices

Include:

Logical component breakdown (backend & frontend layers)

Folder structure for both Django and React

Recommended libraries and tools for each part

Suggested patterns (e.g., service layer, serializers, token handling)

Security considerations

Deployment setup (Docker, CI/CD pipeline outline)

Present the full system architecture visually (as a textual diagram or hierarchy)

Ensure the architecture supports future extensions like real-time task updates (WebSocket) and notifications.
```

### Context
- **Date**: Current session
- **Technology Stack**: Django + React + PostgreSQL + JWT
- **Scope**: Full-stack architecture design for project management application
- **Requirements**: Authentication, RBAC, CRUD operations, real-time features

### Categories
- Architecture Design
- System Planning
- Full-Stack Development
- Django/React Integration
- Security & Deployment

---

## Architecture Options Comparison

### Original Prompt
```
You are an expert full-stack software architect.

I am building a Project Management Application using the following tech stack:

Backend: Python (Django + Django REST Framework)

Frontend: React.js (Single Page Application)

Database: PostgreSQL (strictly)

Authentication: JWT using djangorestframework-simplejwt

The core features include:

User Authentication (Login, Signup, Logout)

Role-based Access Control (Admin, Manager, Developer)

Project Management (CRUD: Create, Read, Update, Delete projects)

Task Management (CRUD tasks, assign users, set statuses & due dates)

Task Comments (Add/view comments with timestamps per task)

Your tasks:

Design 2 or 3 distinct architecture options that fulfill the requirements, allowing us to compare and select the best fit. Each should follow industry best practices and be scalable and modular.

For each architecture option, include:

Logical component breakdown (Frontend + Backend layers)

Suggested folder structure for both Django and React

Recommended libraries/tools (with purpose per section)

Design patterns to use (e.g., service layer, repository pattern, token handling)

Security best practices (e.g., CSRF protection, JWT storage, permission handling)

Deployment setup (Dockerfile + docker-compose overview, CI/CD suggestion like GitHub Actions)

Textual architecture diagram (tree format or ASCII block)

Ensure each option supports future extensibility:

Real-time task updates using WebSockets (e.g., Django Channels)

In-app and email notifications system

Do not generate actual implementation code at this stage. Only focus on architecture planning and justification.
```

### Context
- **Date**: Current session
- **Technology Stack**: Django + React + PostgreSQL + JWT
- **Scope**: Multiple architecture options comparison for project management application
- **Requirements**: Authentication, RBAC, CRUD operations, real-time features, extensibility

### Categories
- Architecture Comparison
- System Design
- Scalability Planning
- Technology Evaluation
- Decision Making

---

## Architecture Recommendation & Selection

### Original Prompt
```
@architecture-options.md

You are an expert full-stack architect.

Given the architectural options listed in the above file and my tech stack:

- Backend: Django (Python)
- Frontend: React (SPA)
- Database: PostgreSQL
- Auth: JWT (via djangorestframework-simplejwt)

Help me **choose the best architecture** among the options by evaluating:
- Scalability
- Maintainability
- Development complexity
- Deployment setup
- PostgreSQL compatibility
- Team collaboration
- Support for real-time updates and background tasks
- Future extensibility

Please recommend the **most suitable option** with a clear explanation and trade-offs.
```

### Context
- **Date**: Current session
- **Technology Stack**: Django + React + PostgreSQL + JWT
- **Scope**: Architecture evaluation and recommendation based on specific criteria
- **Requirements**: Decision-making framework for architecture selection

### Categories
- Architecture Evaluation
- Decision Making
- Technology Assessment
- Project Planning
- Risk Analysis 