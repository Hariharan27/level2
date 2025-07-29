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
- **Requirements**: Scalable, modular, extensible architectures with real-time features

### Categories
- Architecture Design
- System Planning
- Architecture Comparison
- Full-Stack Development
- Django/React Integration

---

## Architecture Recommendation & Selection

### Original Prompt
```
You are an expert full-stack architect. Given the architectural options listed in the above file and my tech stack:

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
- **Scope**: Architecture selection and recommendation based on comparison
- **Requirements**: Best fit evaluation with trade-offs analysis

### Categories
- Architecture Selection
- System Planning
- Decision Making
- Full-Stack Development
- Django/React Integration

### Recommendation Output
**Selected Architecture**: Monolithic with Service Layer

**Key Decision Factors**:
- **Team Size**: Small to medium teams benefit from monolithic simplicity
- **Development Speed**: Faster initial development and deployment
- **PostgreSQL Compatibility**: Single database simplifies data consistency
- **Maintainability**: Easier debugging and cross-cutting concerns
- **Real-time Support**: Django Channels work seamlessly in monolithic setup

**Trade-offs**:
- **Scalability**: Limited compared to microservices (but sufficient for most use cases)
- **Technology Flexibility**: Less flexibility for different tech stacks per service
- **Deployment**: All-or-nothing deployments

**Implementation Priority**:
1. Core Django application with service layer pattern
2. React frontend with API integration
3. PostgreSQL database with proper indexing
4. JWT authentication with role-based access
5. Real-time features with Django Channels
6. Monitoring and deployment setup

---

## Decision Update & Next Steps

### Context Update
**User Decision**: Not proceeding with the monolithic architecture. User wants to enhance the prompt library by adding a new prompt for microservices-based system design.

**Next Architecture Prompt**: Microservices-based architecture design for project management system.

---

## Microservices-Based Architecture Design

### Original Prompt
```
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

### Context
- **Date**: Current session
- **Technology Stack**: React + Django REST Framework + PostgreSQL
- **Scope**: Microservices-based architecture design for project management system
- **Requirements**: Scalable, modular, real-time collaboration, third-party integrations

### Categories
- Microservices Architecture
- System Design
- Scalability Planning
- Django/React Integration
- Real-time Features

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

---

## Initialize Project Structure with AI

### Original Prompt
```
You are a senior full-stack architect. Use the following context from my project:

Files:
1. @microservices-project-architecture.md  → contains detailed microservices-based architecture and inter-service boundaries.
2. @postgresql-microservices-schema.md  → normalized database schema with tables grouped under relevant services.
3. @microservices-api-design.md  → outlines REST API endpoints, request/response formats, and how services interact.

Your goal:
Initialize a clean, production-ready project structure based on the above.

Instructions:

1. **Respect the Architecture**
   - Set up individual services as defined in the architecture (Auth, User, Project, Task, Time, File, Comment, Notification, Analytics).
   - Follow the monorepo structure shown in the Docker Compose configuration.

2. **Reflect the Database Design**
   - Each service owns its corresponding database tables (as per `database-schema.md`).
   - Prepare folder structure to later hold ORM models and migration logic.

3. **Respect the Data Flow**
   - Services that communicate (as per `api-data-flow.md`) should be scaffolded with proper placeholders for API routes and external service clients.

4. **Project Structure & Tools**
   - Use Django + Django REST Framework as specified in the architecture.
   - Create the following structure based on the architecture documents:
     ```
     project-management-system/
     ├── services/                    # Individual microservices (as shown in Docker Compose)
     │   ├── auth-service/
     │   ├── user-service/
     │   ├── project-service/
     │   ├── task-service/
     │   ├── time-service/
     │   ├── file-service/
     │   ├── comment-service/
     │   ├── notification-service/
     │   └── analytics-service/
     ├── frontend/                    # React SPA (as referenced in architecture)
     ├── docker-compose.yml           # Main orchestration (as shown in architecture)
     ├── .env.example                 # Environment variables
     └── README.md                    # Project documentation
     ```
   - Each service should have Django project structure with:
     - Django application code
     - API endpoints
     - Database models
     - Tests
     - Configuration files

5. **Infrastructure Setup**
   - Create Docker Compose configuration as shown in the architecture
   - Set up shared network for inter-service communication
   - Include health check routes (`/health`) for each service
   - Include all infrastructure services: Redis, RabbitMQ, Elasticsearch, Prometheus, Grafana

6. **Do Not Implement Logic**
   - Only generate folder structures, placeholders, configs, and startup commands.
   - Use comments to indicate where logic will go.

7. **Output**
   - Complete tree view of folder structure
   - Docker Compose configuration matching the architecture
   - Environment file templates
   - Startup instructions

Make the scaffold easy to expand during development. Follow the exact structure and naming from the architecture documents.
```

### Context
- **Date**: Current session
- **Technology Stack**: Django + React + PostgreSQL + Docker + Microservices
- **Scope**: Project scaffolding and structure initialization for microservices architecture
- **Requirements**: Production-ready folder structure, Docker orchestration, environment setup

### Categories
- Project Scaffolding
- Microservices Architecture
- Docker Orchestration
- Development Setup
- Infrastructure Configuration

---

## Backend Development Planning Prompt

### Original Prompt
```
You are an expert Django backend architect. I need a detailed implementation plan for my microservices backend development.

## Existing Architecture Documentation
Please reference these files for complete context:
- **@docs/architecture/microservices-project-architecture.md** - Complete microservices architecture with 9 services
- **@docs/architecture/postgresql-microservices-schema.md** - Database schema for all services with table definitions
- **@docs/api/microservices-api-design.md** - API endpoints, request/response formats, and data flow patterns

## Current Project Status
- ✅ Architecture designed and documented (see architecture files above)
- ✅ Database schema ready (PostgreSQL with service boundaries)
- ✅ API endpoints planned (RESTful with standardized formats)
- ✅ Infrastructure scaffolded (Docker Compose with Kong API Gateway)
- ✅ Project structure initialized (9 Django services + React frontend)
- ❌ No actual Django models/views implemented (only templates exist)

## Your Task
Create a detailed backend implementation plan that includes:

### 1. Service Implementation Order
Based on the architecture in @microservices-project-architecture.md:
- Which service to start with and why (Auth Service first)
- Dependencies between services (User → Project → Task → others)
- Parallel development opportunities

### 2. Django Implementation Strategy
Using the database schema from @postgresql-microservices-schema.md:
- Models implementation order for each service
- Views/API endpoints implementation (from @microservices-api-design.md)
- Serializers and validation
- Authentication/authorization setup
- Database migrations strategy

### 3. Core Features Implementation
Following the API design in @microservices-api-design.md:
- User registration/login (Auth Service)
- JWT token management
- User profile management (User Service)
- Project CRUD operations (Project Service)
- Task CRUD operations (Task Service)
- Basic time tracking (Time Service)

### 4. Advanced Features Implementation
- File upload system (File Service)
- Comment system (Comment Service)
- Notification system (Notification Service)
- Analytics and reporting (Analytics Service)

### 5. Testing Strategy
- Unit tests for models
- API endpoint tests (based on @microservices-api-design.md)
- Integration tests between services
- Performance testing

### 6. Security Implementation
- JWT token validation
- Role-based access control
- Input validation and sanitization
- Rate limiting

## Expected Output
Create a comprehensive plan with:
1. Service implementation roadmap (based on architecture dependencies)
2. Django models/views implementation order (using schema definitions)
3. API endpoint development sequence (from API design document)
4. Testing strategy for each service
5. Security implementation checklist
6. Time estimates for each component
7. Risk assessment and mitigation

Make this plan actionable for a 4-5 hour backend development sprint, using the existing architecture as the foundation.
```

### Context
- **Date**: Current session
- **Technology Stack**: Django + PostgreSQL + JWT + Microservices
- **Scope**: Backend implementation planning for microservices architecture
- **Requirements**: Service implementation order, Django models/views, API endpoints, testing strategy

### Categories
- Backend Development
- Django Implementation
- Microservices Architecture
- API Development
- Testing Strategy
- Security Implementation

### Output Quality
- **Comprehensive**: Detailed implementation roadmap
- **Actionable**: Specific steps with time estimates
- **Architecture-Aligned**: Based on existing documentation
- **Risk-Assessed**: Identified potential issues and mitigations

---

## Frontend Development Planning Prompt

### Original Prompt
```
You are an expert React frontend architect. I need a detailed implementation plan for my React SPA frontend development.

## Existing Architecture Documentation
Please reference these files for complete context:
- **@docs/architecture/microservices-project-architecture.md** - Complete microservices architecture with frontend integration
- **@docs/api/microservices-api-design.md** - API endpoints, request/response formats for frontend integration
- **@docs/architecture/postgresql-microservices-schema.md** - Database schema to understand data structures

## Current Project Status
- ✅ React project structure exists in `/frontend/`
- ✅ Component folders created (auth, projects, tasks, time, analytics, common)
- ✅ API service structure ready
- ✅ Infrastructure ready (Docker with Kong API Gateway)
- ❌ No actual React components implemented
- ❌ No API integration implemented

## Your Task
Create a detailed frontend implementation plan that includes:

### 1. Component Implementation Order
Based on the API design in @microservices-api-design.md:
- Which components to build first (Auth → User → Project → Task)
- Component hierarchy and dependencies
- Reusable component identification

### 2. Page Implementation Strategy
Following the microservices architecture in @microservices-project-architecture.md:
- Authentication pages (login/register) - Auth Service integration
- Dashboard layout and navigation - User Service integration
- Project management pages - Project Service integration
- Task management interface - Task Service integration
- Time tracking interface - Time Service integration
- File management interface - File Service integration
- Analytics dashboard - Analytics Service integration

### 3. State Management Strategy
- Global state vs local state
- API state management (using endpoints from @microservices-api-design.md)
- User authentication state
- Real-time updates handling

### 4. API Integration Plan
Using the API design from @microservices-api-design.md:
- Service layer implementation for each microservice
- Error handling strategy (standardized error formats)
- Loading states management
- Data caching strategy

### 5. UI/UX Implementation
- Component library setup
- Responsive design strategy
- Accessibility implementation
- User experience flow

### 6. Advanced Features
- Real-time updates (WebSocket) - Notification Service
- File upload interface - File Service
- Rich text editor for comments - Comment Service
- Data visualization for analytics - Analytics Service

## Expected Output
Create a comprehensive plan with:
1. Component implementation roadmap (based on API dependencies)
2. Page development sequence (following service architecture)
3. State management architecture
4. API integration strategy (using documented endpoints)
5. UI/UX implementation checklist
6. Testing strategy for components
7. Time estimates for each feature
8. Risk assessment and mitigation

Make this plan actionable for a 3-4 hour frontend development sprint, using the existing API design as the foundation.
```

### Context
- **Date**: Current session
- **Technology Stack**: React + Microservices API + State Management
- **Scope**: Frontend implementation planning for React SPA
- **Requirements**: Component architecture, API integration, state management, UI/UX

### Categories
- Frontend Development
- React Implementation
- API Integration
- State Management
- UI/UX Design
- Component Architecture

### Output Quality
- **Comprehensive**: Detailed component roadmap
- **Actionable**: Specific implementation steps
- **API-Aligned**: Based on documented endpoints
- **User-Centric**: Focus on user experience 