# PostgreSQL Schema Design for Microservices Architecture

## Table of Contents
1. [Overview](#overview)
2. [Schema by Microservice](#schema-by-microservice)
3. [Design Decisions](#design-decisions)
4. [Indexes and Performance](#indexes-and-performance)
5. [Phase 2 Enhancements](#phase-2-enhancements)

---

## Overview

This schema design follows the microservices architecture defined in the project management system, with each service owning its database and maintaining clear boundaries. The design prioritizes:

- **Service Autonomy**: Each service owns its data completely
- **Horizontal Scalability**: Schema supports independent scaling
- **Data Consistency**: Proper foreign keys and constraints within services
- **Performance**: Strategic indexing for common query patterns
- **Future Growth**: Extensible design for evolving requirements

---

## Schema by Microservice

### 1. Authentication Service Database (`auth_db`)

```sql
-- =============================================
-- AUTHENTICATION SERVICE DATABASE (auth_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Core user authentication table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles and permissions
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    granted_by UUID REFERENCES users(id),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- JWT refresh tokens
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- OAuth2 integrations
CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL, -- 'google', 'github', 'slack'
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_user_id)
);

-- Password reset tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Email verification tokens
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Authentication Service
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);
CREATE INDEX idx_oauth_accounts_user_id ON oauth_accounts(user_id);
CREATE INDEX idx_oauth_accounts_provider ON oauth_accounts(provider);
```

### 2. User Service Database (`user_db`)

```sql
-- =============================================
-- USER SERVICE DATABASE (user_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles (extends auth service user data)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    avatar_url VARCHAR(500),
    bio TEXT,
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    date_format VARCHAR(20) DEFAULT 'YYYY-MM-DD',
    time_format VARCHAR(10) DEFAULT '24h',
    notification_preferences JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Organizations
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE,
    description TEXT,
    logo_url VARCHAR(500),
    settings JSONB DEFAULT '{}',
    subscription_plan VARCHAR(50) DEFAULT 'free',
    subscription_expires_at TIMESTAMP,
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teams within organizations
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL, -- References auth_db.users.id (external)
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team members
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- 'owner', 'admin', 'member'
    permissions JSONB DEFAULT '{}',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID, -- References auth_db.users.id (external)
    status VARCHAR(20) DEFAULT 'active' -- 'active', 'pending', 'suspended'
);

-- Organization members
CREATE TABLE organization_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- 'owner', 'admin', 'member'
    permissions JSONB DEFAULT '{}',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID -- References auth_db.users.id (external)
);

-- User invitations
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    invited_by UUID NOT NULL, -- References auth_db.users.id (external)
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User activity tracking
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    activity_type VARCHAR(100) NOT NULL,
    activity_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for User Service
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_organizations_domain ON organizations(domain);
CREATE INDEX idx_teams_organization_id ON teams(organization_id);
CREATE INDEX idx_teams_owner_id ON teams(owner_id);
CREATE INDEX idx_team_members_team_id ON team_members(team_id);
CREATE INDEX idx_team_members_user_id ON team_members(user_id);
CREATE INDEX idx_team_members_status ON team_members(status);
CREATE INDEX idx_organization_members_org_id ON organization_members(organization_id);
CREATE INDEX idx_organization_members_user_id ON organization_members(user_id);
CREATE INDEX idx_invitations_email ON invitations(email);
CREATE INDEX idx_invitations_token ON invitations(token_hash);
CREATE INDEX idx_invitations_expires ON invitations(expires_at);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at);
```

### 3. Project Service Database (`project_db`)

```sql
-- =============================================
-- PROJECT SERVICE DATABASE (project_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'on_hold', 'cancelled'
    start_date DATE,
    end_date DATE,
    owner_id UUID NOT NULL, -- References auth_db.users.id (external)
    organization_id UUID, -- References user_db.organizations.id (external)
    team_id UUID, -- References user_db.teams.id (external)
    settings JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project milestones
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'overdue'
    completed_at TIMESTAMP,
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project members
CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- 'owner', 'manager', 'member', 'viewer'
    permissions JSONB DEFAULT '{}',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID -- References auth_db.users.id (external)
);

-- Project templates
CREATE TABLE project_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_data JSONB NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    organization_id UUID, -- References user_db.organizations.id (external)
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project categories/tags
CREATE TABLE project_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color
    organization_id UUID, -- References user_db.organizations.id (external)
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project-category relationships
CREATE TABLE project_category_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES project_categories(id) ON DELETE CASCADE,
    assigned_by UUID NOT NULL, -- References auth_db.users.id (external)
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, category_id)
);

-- Project activity log
CREATE TABLE project_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    activity_type VARCHAR(100) NOT NULL,
    activity_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Project Service
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_projects_organization_id ON projects(organization_id);
CREATE INDEX idx_projects_team_id ON projects(team_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_dates ON projects(start_date, end_date);
CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_milestones_status ON milestones(status);
CREATE INDEX idx_milestones_due_date ON milestones(due_date);
CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);
CREATE INDEX idx_project_templates_created_by ON project_templates(created_by);
CREATE INDEX idx_project_templates_organization ON project_templates(organization_id);
CREATE INDEX idx_project_categories_organization ON project_categories(organization_id);
CREATE INDEX idx_project_activities_project_id ON project_activities(project_id);
CREATE INDEX idx_project_activities_created_at ON project_activities(created_at);
```

### 4. Task Service Database (`task_db`)

```sql
-- =============================================
-- TASK SERVICE DATABASE (task_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tasks
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    project_id UUID NOT NULL, -- References project_db.projects.id (external)
    assigned_to UUID, -- References auth_db.users.id (external)
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    status VARCHAR(50) DEFAULT 'todo', -- 'todo', 'in_progress', 'review', 'done', 'cancelled'
    priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    due_date TIMESTAMP,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    tags TEXT[],
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task dependencies
CREATE TABLE task_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    dependency_type VARCHAR(50) DEFAULT 'finish_to_start', -- 'finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish'
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (task_id != depends_on_task_id)
);

-- Task templates
CREATE TABLE task_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_data JSONB NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    organization_id UUID, -- References user_db.organizations.id (external)
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task attachments (references to file service)
CREATE TABLE task_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    file_id UUID NOT NULL, -- References file_db.files.id (external)
    uploaded_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task time estimates
CREATE TABLE task_time_estimates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    estimated_by UUID NOT NULL, -- References auth_db.users.id (external)
    estimated_hours DECIMAL(5,2) NOT NULL,
    estimation_type VARCHAR(50) DEFAULT 'initial', -- 'initial', 'revised', 'final'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task activity log
CREATE TABLE task_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    activity_type VARCHAR(100) NOT NULL,
    activity_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task labels/categories
CREATE TABLE task_labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color
    project_id UUID, -- References project_db.projects.id (external)
    organization_id UUID, -- References user_db.organizations.id (external)
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task-label relationships
CREATE TABLE task_label_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    label_id UUID NOT NULL REFERENCES task_labels(id) ON DELETE CASCADE,
    assigned_by UUID NOT NULL, -- References auth_db.users.id (external)
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_id, label_id)
);

-- Indexes for Task Service
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_tags ON tasks USING GIN(tags);
CREATE INDEX idx_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX idx_task_dependencies_depends_on ON task_dependencies(depends_on_task_id);
CREATE INDEX idx_task_attachments_task_id ON task_attachments(task_id);
CREATE INDEX idx_task_attachments_file_id ON task_attachments(file_id);
CREATE INDEX idx_task_time_estimates_task_id ON task_time_estimates(task_id);
CREATE INDEX idx_task_activities_task_id ON task_activities(task_id);
CREATE INDEX idx_task_activities_created_at ON task_activities(created_at);
CREATE INDEX idx_task_labels_project_id ON task_labels(project_id);
CREATE INDEX idx_task_labels_organization_id ON task_labels(organization_id);
```

### 5. Comment Service Database (`comment_db`)

```sql
-- =============================================
-- COMMENT SERVICE DATABASE (comment_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Comments
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    author_id UUID NOT NULL, -- References auth_db.users.id (external)
    entity_type VARCHAR(50) NOT NULL, -- 'task', 'project', 'milestone'
    entity_id UUID NOT NULL, -- References respective service tables (external)
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    is_edited BOOLEAN DEFAULT FALSE,
    edit_history JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comment reactions
CREATE TABLE comment_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    reaction_type VARCHAR(20) NOT NULL, -- 'like', 'heart', 'thumbs_up', 'thumbs_down', 'laugh', 'sad'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(comment_id, user_id, reaction_type)
);

-- Comment mentions
CREATE TABLE comment_mentions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    mentioned_user_id UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comment attachments (references to file service)
CREATE TABLE comment_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    file_id UUID NOT NULL, -- References file_db.files.id (external)
    uploaded_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comment activity log
CREATE TABLE comment_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    activity_type VARCHAR(100) NOT NULL, -- 'created', 'edited', 'deleted', 'replied'
    activity_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Comment Service
CREATE INDEX idx_comments_entity ON comments(entity_type, entity_id);
CREATE INDEX idx_comments_author_id ON comments(author_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
CREATE INDEX idx_comment_reactions_comment_id ON comment_reactions(comment_id);
CREATE INDEX idx_comment_reactions_user_id ON comment_reactions(user_id);
CREATE INDEX idx_comment_mentions_comment_id ON comment_mentions(comment_id);
CREATE INDEX idx_comment_mentions_user_id ON comment_mentions(mentioned_user_id);
CREATE INDEX idx_comment_attachments_comment_id ON comment_attachments(comment_id);
CREATE INDEX idx_comment_activities_comment_id ON comment_activities(comment_id);
```

### 6. Time Tracking Service Database (`time_db`)

```sql
-- =============================================
-- TIME TRACKING SERVICE DATABASE (time_db)
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Time entries
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    task_id UUID, -- References task_db.tasks.id (external)
    project_id UUID, -- References project_db.projects.id (external)
    description TEXT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_minutes INTEGER,
    billable BOOLEAN DEFAULT TRUE,
    hourly_rate DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'paused', 'completed', 'deleted'
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Timesheets
CREATE TABLE timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    week_start_date DATE NOT NULL,
    total_hours DECIMAL(5,2) DEFAULT 0,
    billable_hours DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'submitted', 'approved', 'rejected'
    submitted_at TIMESTAMP,
    approved_by UUID, -- References auth_db.users.id (external)
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Timesheet entries (junction table)
CREATE TABLE timesheet_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_id UUID NOT NULL REFERENCES timesheets(id) ON DELETE CASCADE,
    time_entry_id UUID NOT NULL, -- References time_entries.id
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(timesheet_id, time_entry_id)
);

-- Hourly rates
CREATE TABLE hourly_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    project_id UUID, -- References project_db.projects.id (external)
    rate DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    effective_date DATE NOT NULL,
    end_date DATE,
    created_by UUID NOT NULL, -- References auth_db.users.id (external)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Time tracking settings
CREATE TABLE time_tracking_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    organization_id UUID, -- References user_db.organizations.id (external)
    auto_start_timer BOOLEAN DEFAULT FALSE,
    round_time_to_minutes INTEGER DEFAULT 15,
    default_billable BOOLEAN DEFAULT TRUE,
    default_hourly_rate DECIMAL(10,2),
    timezone VARCHAR(50) DEFAULT 'UTC',
    work_hours JSONB DEFAULT '{"monday": {"start": "09:00", "end": "17:00"}, "tuesday": {"start": "09:00", "end": "17:00"}, "wednesday": {"start": "09:00", "end": "17:00"}, "thursday": {"start": "09:00", "end": "17:00"}, "friday": {"start": "09:00", "end": "17:00"}}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Time tracking activity log
CREATE TABLE time_tracking_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- References auth_db.users.id (external)
    activity_type VARCHAR(100) NOT NULL, -- 'start_timer', 'stop_timer', 'pause_timer', 'resume_timer'
    time_entry_id UUID, -- References time_entries.id
    activity_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Time Tracking Service
CREATE INDEX idx_time_entries_user_id ON time_entries(user_id);
CREATE INDEX idx_time_entries_task_id ON time_entries(task_id);
CREATE INDEX idx_time_entries_project_id ON time_entries(project_id);
CREATE INDEX idx_time_entries_start_time ON time_entries(start_time);
CREATE INDEX idx_time_entries_end_time ON time_entries(end_time);
CREATE INDEX idx_time_entries_status ON time_entries(status);
CREATE INDEX idx_timesheets_user_id ON timesheets(user_id);
CREATE INDEX idx_timesheets_week_start ON timesheets(week_start_date);
CREATE INDEX idx_timesheets_status ON timesheets(status);
CREATE INDEX idx_timesheet_entries_timesheet_id ON timesheet_entries(timesheet_id);
CREATE INDEX idx_timesheet_entries_time_entry_id ON timesheet_entries(time_entry_id);
CREATE INDEX idx_hourly_rates_user_id ON hourly_rates(user_id);
CREATE INDEX idx_hourly_rates_project_id ON hourly_rates(project_id);
CREATE INDEX idx_hourly_rates_effective_date ON hourly_rates(effective_date);
CREATE INDEX idx_time_tracking_settings_user_id ON time_tracking_settings(user_id);
CREATE INDEX idx_time_tracking_activities_user_id ON time_tracking_activities(user_id);
CREATE INDEX idx_time_tracking_activities_created_at ON time_tracking_activities(created_at);
```

---

## Design Decisions

### 1. **Service Boundary Respect**

**External References**: All foreign keys that reference data in other services are marked as external and don't have actual foreign key constraints. This prevents cross-service dependencies and maintains service autonomy.

**Example**:
```sql
-- Internal reference (within same service)
project_id UUID REFERENCES projects(id) ON DELETE CASCADE

-- External reference (to another service)
user_id UUID NOT NULL, -- References auth_db.users.id (external)
```

### 2. **UUID Primary Keys**

**Rationale**: 
- Enables horizontal scaling without ID conflicts
- Supports distributed systems and eventual consistency
- Prevents enumeration attacks
- Allows for offline ID generation

### 3. **Consistent Timestamp Fields**

**Pattern**: All tables include `created_at` and `updated_at` for audit trails and data consistency.

### 4. **JSONB for Flexible Data**

**Usage**: 
- `settings` and `metadata` fields for extensible configuration
- `permissions` for role-based access control
- `activity_data` for detailed audit logs

### 5. **Strategic Indexing**

**Approach**:
- Foreign keys for join performance
- Status fields for filtering
- Date fields for time-based queries
- GIN indexes for array fields (tags)

---

## Indexes and Performance

### **Composite Indexes for Common Queries**

```sql
-- Project service: Find projects by organization and status
CREATE INDEX idx_projects_org_status ON projects(organization_id, status);

-- Task service: Find tasks by project and assignee
CREATE INDEX idx_tasks_project_assignee ON tasks(project_id, assigned_to);

-- Time service: Find time entries by user and date range
CREATE INDEX idx_time_entries_user_date ON time_entries(user_id, start_time, end_time);

-- Comment service: Find comments by entity with pagination
CREATE INDEX idx_comments_entity_created ON comments(entity_type, entity_id, created_at);
```

### **Partial Indexes for Active Data**

```sql
-- Only index active projects
CREATE INDEX idx_projects_active ON projects(organization_id, status) 
WHERE status = 'active';

-- Only index active time entries
CREATE INDEX idx_time_entries_active ON time_entries(user_id, start_time) 
WHERE status = 'active';
```

---

## Phase 2 Enhancements

### 1. **Soft Deletes**

```sql
-- Add to all tables
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;
ALTER TABLE projects ADD COLUMN deleted_at TIMESTAMP;
ALTER TABLE tasks ADD COLUMN deleted_at TIMESTAMP;
-- ... etc

-- Create partial indexes for non-deleted records
CREATE INDEX idx_users_active_only ON users(id) WHERE deleted_at IS NULL;
```

### 2. **Audit Trail Support**

```sql
-- Audit trail table for all services
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_values JSONB,
    new_values JSONB,
    changed_by UUID NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. **Event Sourcing**

```sql
-- Event store for domain events
CREATE TABLE domain_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    event_version INTEGER NOT NULL,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event subscriptions
CREATE TABLE event_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscriber_name VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    last_processed_event_id UUID,
    last_processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. **Multi-tenancy Design**

```sql
-- Add tenant_id to all tables
ALTER TABLE users ADD COLUMN tenant_id UUID;
ALTER TABLE projects ADD COLUMN tenant_id UUID;
-- ... etc

-- Create tenant-aware indexes
CREATE INDEX idx_users_tenant ON users(tenant_id, id);
CREATE INDEX idx_projects_tenant ON projects(tenant_id, id);
```

### 5. **Schema Versioning**

```sql
-- Schema version tracking
CREATE TABLE schema_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version VARCHAR(50) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);
```

### 6. **Enum Types and Lookup Tables**

```sql
-- Create enum types
CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'review', 'done', 'cancelled');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Lookup tables for configurable values
CREATE TABLE status_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status_key VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0
);
```

### 7. **Performance Optimizations**

```sql
-- Partitioning for large tables
CREATE TABLE time_entries_2024 PARTITION OF time_entries
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Materialized views for complex queries
CREATE MATERIALIZED VIEW project_summary AS
SELECT 
    p.id,
    p.name,
    COUNT(t.id) as total_tasks,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) as completed_tasks,
    SUM(te.duration_minutes) as total_minutes
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
LEFT JOIN time_entries te ON t.id = te.task_id
GROUP BY p.id, p.name;
```

This schema design provides a solid foundation for a scalable microservices architecture while maintaining clear service boundaries and supporting future enhancements. 