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

### Recommendation Output
**Selected Architecture: Option 1 - Monolithic with Service Layer**

**Key Decision Factors:**
- ✅ Perfect match for Django + React + PostgreSQL + JWT stack
- ✅ Fastest time to market with familiar patterns
- ✅ Excellent PostgreSQL utilization in single database
- ✅ Simple deployment with Docker + Nginx
- ✅ Easy team onboarding with standard skills
- ✅ Clear evolution path to microservices when needed

**Trade-offs:**
- ⚠️ Limited horizontal scaling (mitigated with load balancers)
- ⚠️ Single point of failure (mitigated with monitoring)
- ⚠️ Technology lock-in to Django ecosystem

**Implementation Priority:**
1. Start with monolithic foundation
2. Implement service layer pattern for clean separation
3. Plan for future service extraction based on growth metrics
4. Consider event-driven patterns for specific high-performance domains

---

## Decision Update & Next Steps

### Current Status
**Note: I am not proceeding with the monolithic architecture recommendation.**
After careful consideration, I've decided to explore alternative architecture approaches that better align with my specific requirements and long-term vision.

### Next Architecture Prompt
```
@project-architecture.md

You are an expert software architect. I want you to help me design a scalable and modular system architecture based on the following requirements. Please provide a clear, detailed breakdown with rationale for each decision.

---

## Business Context
Development teams need to track project progress and resource allocation efficiently in real time.

---

## Core Requirements
1. **Project Creation**: Users can create projects with timelines and milestones.
2. **Task Management**: Tasks can be created, prioritized, and assigned to team members.
3. **Progress Tracking**: Visual indicators (e.g., Gantt charts, percent complete) and status updates.
4. **Team Collaboration**: Commenting system, file attachments, and notifications.
5. **Time Tracking**: Users can log hours spent on tasks and projects.

---

## Technical Stack (Strict)
- **Frontend**: React
- **Backend**: Python with Django REST Framework
- **Database**: PostgreSQL

---

## Architecture Goal
Design a production-ready, microservices-based architecture that ensures:
- Scalability
- Separation of concerns
- Maintainability
- Real-time collaboration (if needed)
- Easy integration with third-party tools (like Slack or GitHub)
- Developer-friendly APIs
- Clear division of services (example: auth, projects, tasks, time-tracking)

---

## Expected Output
1. High-level architecture diagram (describe with text block if visual not possible)
2. List of proposed microservices and their responsibilities
3. Database design (schema or ERD format in text)
4. API Gateway or BFF layer (if needed)
5. Auth mechanism (JWT/OAuth2)
6. File upload and notifications strategy
7. Optional: CI/CD, monitoring/logging recommendations

---

Please generate a detailed architectural document based on the above.
```

### Context for Next Iteration
- **Previous Decision**: Rejected monolithic approach
- **Reasoning**: Need for microservices architecture with clear service boundaries
- **Next Focus**: Microservices-based architecture with 9 distinct services

---

## PostgreSQL Schema Design for Microservices

### Original Prompt
```
You are a seasoned software architect specializing in designing scalable microservice-based systems using PostgreSQL.

Refer to the architecture described in @microservices-project-architecture.md  . Use the service names and boundaries **exactly as defined there** — do not rename, re-define, or modify the services. Reference them when grouping the schema.

Your task is to design a normalized and scalable PostgreSQL schema that aligns with this architecture.

Requirements:

1. Define tables for core entities: `User`, `Project`, `Task`, `Comment`, and `TimeLog`.
2. Organize the SQL `CREATE TABLE` statements by microservice ownership **based on the architecture**, such as:
   - User Service
   - Project Service
   - Task Service
   - Comment Service
   - Time Tracking Service
3. Use proper SQL best practices:
   - UUIDs for primary keys
   - `created_at`, `updated_at` timestamp columns
   - Foreign keys with cascading behavior (where appropriate)
   - Indexes on foreign keys and commonly queried fields
   - Constraints such as `NOT NULL`, `UNIQUE`, etc.
4. Respect microservice boundaries:
   - Avoid direct joins across services
   - Clearly indicate foreign keys that reference data in another service (e.g., using `external_project_id`)
   - Mark ownership of each table based on its service
5. Follow consistent naming conventions:
   - Snake_case for tables and fields
   - Plural table names if appropriate

Deliverables:

1. SQL `CREATE TABLE` statements grouped by microservice in a markdown code block.
2. A brief explanation of key design decisions:
   - Why certain relationships were modeled a certain way
   - How you ensured decoupling and service autonomy
   - Why certain indexes and constraints were applied
3. A list of suggested enhancements for Phase 2, such as:
   - Soft deletes using a `deleted_at` column
   - Audit trail support
   - Event sourcing
   - Multi-tenancy design
   - Schema versioning
   - Use of enum types or lookup tables

Assume horizontal scalability is a key requirement, and structure the schema to accommodate future modular growth.
```

### Context
- **Date**: Current session
- **Technology Stack**: PostgreSQL + Microservices Architecture
- **Scope**: Database schema design for microservices with clear service boundaries
- **Requirements**: Normalized schema, service autonomy, horizontal scalability

### Categories
- Database Design
- Microservices Architecture
- PostgreSQL Optimization
- Schema Planning
- Service Boundaries

---

## Microservices API Design & Data Flow

### Original Prompt
```
You are a senior backend engineer with expertise in designing APIs for microservices architectures.

Refer to the architecture defined in @microservices-project-architecture.md  and the database schema in @postgresql-microservices-schema.md.

Your task:
Design service-level RESTful API endpoints and illustrate the data flow between services.

Expectations:
- Break down endpoints by microservice (e.g., User Service, Project Service, Task Service, etc.)
- For each endpoint, define:
  - HTTP method and path
  - Expected request and response structure (brief JSON format)
  - Authentication/authorization requirements
- Specify which services communicate internally and how (REST, event-driven, etc.)
- Define error-handling strategy and standard response formats
- Mention any pagination, filtering, or rate limiting where applicable

Present the output in:
1. A markdown section with endpoints grouped by service
2. A data flow diagram or explanation of how services interact (e.g., Task Service queries User Service for assignee)
3. A table of standardized error responses used across all APIs
```

### Context
- **Date**: Current session
- **Technology Stack**: RESTful APIs + Microservices Architecture
- **Scope**: API design for microservices with data flow patterns
- **Requirements**: Service endpoints, cross-service communication, error handling

### Categories
- API Design
- Microservices Architecture
- RESTful APIs
- Service Communication
- Error Handling
- Data Flow Patterns 