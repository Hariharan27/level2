# Frontend Implementation Plan - React SPA

## Executive Summary

This plan provides a detailed roadmap for implementing the React frontend that integrates with the 9 microservices backend. The implementation follows a component-driven approach, starting with authentication and core features, then progressing to advanced functionality.

## Current Status Assessment

### ✅ Completed
- **React Project Structure**: Basic folder structure exists
- **Component Folders**: auth, projects, tasks, time, analytics, common
- **API Service Structure**: Ready for integration
- **Infrastructure**: Docker setup with Kong API Gateway

### ❌ Missing
- **React Components**: No actual components implemented
- **API Integration**: No service layer implementation
- **State Management**: No global state setup
- **Authentication Flow**: No login/register functionality
- **Routing**: No navigation between pages

---

## 1. Component Implementation Order

### Phase 1: Core Foundation (2-3 hours)
**Priority: CRITICAL - Start Here**

#### 1.1 Authentication Components (1-1.5 hours)
**Why First**: Required for all other functionality
- **Dependencies**: None (foundational)
- **Key Components**:
  - LoginForm
  - RegisterForm
  - PasswordResetForm
  - AuthContext (global state)
  - ProtectedRoute

#### 1.2 Layout & Navigation (1-1.5 hours)
**Dependencies**: Authentication components
- **Key Components**:
  - MainLayout
  - Sidebar
  - Header
  - Navigation
  - Breadcrumbs

### Phase 2: Core Business Logic (2-3 hours)
**Priority: HIGH**

#### 2.1 User Management Components (1-1.5 hours)
**Dependencies**: Authentication, Layout
- **Key Components**:
  - UserProfile
  - TeamManagement
  - OrganizationSettings
  - UserSearch

#### 2.2 Project Management Components (1-1.5 hours)
**Dependencies**: User Management
- **Key Components**:
  - ProjectList
  - ProjectDetail
  - ProjectForm
  - ProjectDashboard
  - MilestoneManagement

### Phase 3: Task Management (2-3 hours)
**Priority: HIGH**

#### 3.1 Task Components (1-1.5 hours)
**Dependencies**: Project Management
- **Key Components**:
  - TaskList
  - TaskDetail
  - TaskForm
  - TaskBoard (Kanban)
  - TaskFilters

#### 3.2 Time Tracking Components (1-1.5 hours)
**Dependencies**: Task Management
- **Key Components**:
  - TimeEntryForm
  - TimeTracker
  - TimesheetView
  - TimeAnalytics

### Phase 4: Supporting Features (1-2 hours)
**Priority: MEDIUM**

#### 4.1 File Management (0.5-1 hour)
**Dependencies**: Project/Task Management
- **Key Components**:
  - FileUpload
  - FileList
  - FilePreview
  - FileSharing

#### 4.2 Comments & Collaboration (0.5-1 hour)
**Dependencies**: Task Management
- **Key Components**:
  - CommentList
  - CommentForm
  - MentionSystem
  - ReactionSystem

### Phase 5: Advanced Features (1-2 hours)
**Priority: LOW**

#### 5.1 Notifications (0.5-1 hour)
**Dependencies**: All other components
- **Key Components**:
  - NotificationCenter
  - NotificationItem
  - NotificationPreferences

#### 5.2 Analytics Dashboard (0.5-1 hour)
**Dependencies**: All other components
- **Key Components**:
  - AnalyticsDashboard
  - ProjectMetrics
  - TimeAnalytics
  - TeamPerformance

---

## 2. Page Implementation Strategy

### 2.1 Authentication Pages

#### Login Page
```jsx
// pages/auth/LoginPage.jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import LoginForm from '../../components/auth/LoginForm';
import { Container, Card, Alert } from '../../components/common';

const LoginPage = () => {
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (credentials) => {
    try {
      await login(credentials);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <Container>
      <Card>
        <h1>Login</h1>
        {error && <Alert type="error">{error}</Alert>}
        <LoginForm onSubmit={handleLogin} />
      </Card>
    </Container>
  );
};

export default LoginPage;
```

#### Register Page
```jsx
// pages/auth/RegisterPage.jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import RegisterForm from '../../components/auth/RegisterForm';
import { Container, Card, Alert } from '../../components/common';

const RegisterPage = () => {
  const [error, setError] = useState('');
  const { register } = useAuth();
  const navigate = useNavigate();

  const handleRegister = async (userData) => {
    try {
      await register(userData);
      navigate('/login', { 
        state: { message: 'Registration successful! Please check your email.' }
      });
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <Container>
      <Card>
        <h1>Create Account</h1>
        {error && <Alert type="error">{error}</Alert>}
        <RegisterForm onSubmit={handleRegister} />
      </Card>
    </Container>
  );
};

export default RegisterPage;
```

### 2.2 Dashboard Layout

#### Main Dashboard
```jsx
// pages/dashboard/DashboardPage.jsx
import React from 'react';
import { useAuth } from '../../hooks/useAuth';
import { useProjects } from '../../hooks/useProjects';
import { useTasks } from '../../hooks/useTasks';
import { 
  Container, 
  ProjectCard, 
  TaskCard, 
  TimeTracker,
  AnalyticsWidget 
} from '../../components';

const DashboardPage = () => {
  const { user } = useAuth();
  const { projects, loading: projectsLoading } = useProjects();
  const { tasks, loading: tasksLoading } = useTasks();

  if (projectsLoading || tasksLoading) {
    return <div>Loading...</div>;
  }

  return (
    <Container>
      <h1>Welcome back, {user.first_name}!</h1>
      
      <div className="dashboard-grid">
        <div className="dashboard-section">
          <h2>Recent Projects</h2>
          {projects.slice(0, 3).map(project => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </div>
        
        <div className="dashboard-section">
          <h2>My Tasks</h2>
          {tasks.slice(0, 5).map(task => (
            <TaskCard key={task.id} task={task} />
          ))}
        </div>
        
        <div className="dashboard-section">
          <h2>Time Tracking</h2>
          <TimeTracker />
        </div>
        
        <div className="dashboard-section">
          <h2>Analytics</h2>
          <AnalyticsWidget />
        </div>
      </div>
    </Container>
  );
};

export default DashboardPage;
```

### 2.3 Project Management Pages

#### Project List Page
```jsx
// pages/projects/ProjectListPage.jsx
import React, { useState } from 'react';
import { useProjects } from '../../hooks/useProjects';
import { 
  Container, 
  ProjectCard, 
  ProjectFilters, 
  CreateProjectButton,
  SearchBar 
} from '../../components';

const ProjectListPage = () => {
  const [filters, setFilters] = useState({
    status: 'all',
    search: '',
    sortBy: 'created_at'
  });
  
  const { projects, loading, createProject } = useProjects();

  const filteredProjects = projects.filter(project => {
    if (filters.status !== 'all' && project.status !== filters.status) {
      return false;
    }
    if (filters.search && !project.name.toLowerCase().includes(filters.search.toLowerCase())) {
      return false;
    }
    return true;
  });

  return (
    <Container>
      <div className="page-header">
        <h1>Projects</h1>
        <CreateProjectButton onCreate={createProject} />
      </div>
      
      <div className="filters-section">
        <SearchBar 
          value={filters.search}
          onChange={(search) => setFilters(prev => ({ ...prev, search }))}
          placeholder="Search projects..."
        />
        <ProjectFilters 
          filters={filters}
          onFiltersChange={setFilters}
        />
      </div>
      
      <div className="projects-grid">
        {filteredProjects.map(project => (
          <ProjectCard key={project.id} project={project} />
        ))}
      </div>
    </Container>
  );
};

export default ProjectListPage;
```

---

## 3. State Management Strategy

### 3.1 Global State Architecture

#### Auth Context
```jsx
// contexts/AuthContext.jsx
import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { authService } from '../services/authService';

const AuthContext = createContext();

const initialState = {
  user: null,
  token: localStorage.getItem('access_token'),
  isAuthenticated: false,
  loading: true
};

const authReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload.user,
        token: action.payload.access_token,
        isAuthenticated: true,
        loading: false
      };
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        loading: false
      };
    case 'SET_LOADING':
      return {
        ...state,
        loading: action.payload
      };
    default:
      return state;
  }
};

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  useEffect(() => {
    const initializeAuth = async () => {
      if (state.token) {
        try {
          const user = await authService.getProfile();
          dispatch({ type: 'LOGIN_SUCCESS', payload: { user, access_token: state.token } });
        } catch (error) {
          localStorage.removeItem('access_token');
          dispatch({ type: 'LOGOUT' });
        }
      } else {
        dispatch({ type: 'SET_LOADING', payload: false });
      }
    };

    initializeAuth();
  }, []);

  const login = async (credentials) => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      const response = await authService.login(credentials);
      localStorage.setItem('access_token', response.access_token);
      dispatch({ type: 'LOGIN_SUCCESS', payload: response });
    } catch (error) {
      dispatch({ type: 'SET_LOADING', payload: false });
      throw error;
    }
  };

  const logout = () => {
    localStorage.removeItem('access_token');
    dispatch({ type: 'LOGOUT' });
  };

  const value = {
    ...state,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

#### Project Context
```jsx
// contexts/ProjectContext.jsx
import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { projectService } from '../services/projectService';

const ProjectContext = createContext();

const initialState = {
  projects: [],
  currentProject: null,
  loading: false,
  error: null
};

const projectReducer = (state, action) => {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_PROJECTS':
      return { ...state, projects: action.payload, loading: false };
    case 'SET_CURRENT_PROJECT':
      return { ...state, currentProject: action.payload };
    case 'ADD_PROJECT':
      return { ...state, projects: [...state.projects, action.payload] };
    case 'UPDATE_PROJECT':
      return {
        ...state,
        projects: state.projects.map(p => 
          p.id === action.payload.id ? action.payload : p
        )
      };
    case 'DELETE_PROJECT':
      return {
        ...state,
        projects: state.projects.filter(p => p.id !== action.payload)
      };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    default:
      return state;
  }
};

export const ProjectProvider = ({ children }) => {
  const [state, dispatch] = useReducer(projectReducer, initialState);

  const fetchProjects = async () => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      const projects = await projectService.getProjects();
      dispatch({ type: 'SET_PROJECTS', payload: projects });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
    }
  };

  const createProject = async (projectData) => {
    try {
      const newProject = await projectService.createProject(projectData);
      dispatch({ type: 'ADD_PROJECT', payload: newProject });
      return newProject;
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
      throw error;
    }
  };

  const updateProject = async (id, projectData) => {
    try {
      const updatedProject = await projectService.updateProject(id, projectData);
      dispatch({ type: 'UPDATE_PROJECT', payload: updatedProject });
      return updatedProject;
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
      throw error;
    }
  };

  const deleteProject = async (id) => {
    try {
      await projectService.deleteProject(id);
      dispatch({ type: 'DELETE_PROJECT', payload: id });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
      throw error;
    }
  };

  const value = {
    ...state,
    fetchProjects,
    createProject,
    updateProject,
    deleteProject
  };

  return (
    <ProjectContext.Provider value={value}>
      {children}
    </ProjectContext.Provider>
  );
};

export const useProjects = () => {
  const context = useContext(ProjectContext);
  if (!context) {
    throw new Error('useProjects must be used within a ProjectProvider');
  }
  return context;
};
```

### 3.2 API State Management

#### Service Layer Implementation
```jsx
// services/apiService.js
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
apiClient.interceptors.response.use(
  (response) => {
    return response.data;
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token');
      window.location.href = '/login';
    }
    return Promise.reject(error.response?.data || error);
  }
);

export default apiClient;
```

#### Auth Service
```jsx
// services/authService.js
import apiClient from './apiService';

export const authService = {
  async login(credentials) {
    const response = await apiClient.post('/api/v1/auth/login', credentials);
    return response.data;
  },

  async register(userData) {
    const response = await apiClient.post('/api/v1/auth/register', userData);
    return response.data;
  },

  async getProfile() {
    const response = await apiClient.get('/api/v1/users/profile');
    return response.data;
  },

  async refreshToken() {
    const refreshToken = localStorage.getItem('refresh_token');
    const response = await apiClient.post('/api/v1/auth/refresh', {
      refresh_token: refreshToken
    });
    return response.data;
  },

  async logout() {
    await apiClient.post('/api/v1/auth/logout');
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
  }
};
```

#### Project Service
```jsx
// services/projectService.js
import apiClient from './apiService';

export const projectService = {
  async getProjects(params = {}) {
    const response = await apiClient.get('/api/v1/projects', { params });
    return response.data;
  },

  async getProject(id) {
    const response = await apiClient.get(`/api/v1/projects/${id}`);
    return response.data;
  },

  async createProject(projectData) {
    const response = await apiClient.post('/api/v1/projects', projectData);
    return response.data;
  },

  async updateProject(id, projectData) {
    const response = await apiClient.put(`/api/v1/projects/${id}`, projectData);
    return response.data;
  },

  async deleteProject(id) {
    await apiClient.delete(`/api/v1/projects/${id}`);
  },

  async getProjectMilestones(projectId) {
    const response = await apiClient.get(`/api/v1/projects/${projectId}/milestones`);
    return response.data;
  },

  async createMilestone(projectId, milestoneData) {
    const response = await apiClient.post(`/api/v1/projects/${projectId}/milestones`, milestoneData);
    return response.data;
  }
};
```

---

## 4. API Integration Plan

### 4.1 Service-to-Frontend API Mapping

#### Authentication Integration
```jsx
// hooks/useAuth.js
import { useContext } from 'react';
import { AuthContext } from '../contexts/AuthContext';

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

#### Project Integration
```jsx
// hooks/useProjects.js
import { useContext, useEffect } from 'react';
import { ProjectContext } from '../contexts/ProjectContext';

export const useProjects = () => {
  const context = useContext(ProjectContext);
  
  useEffect(() => {
    if (!context.projects.length && !context.loading) {
      context.fetchProjects();
    }
  }, [context]);

  return context;
};
```

### 4.2 Error Handling Strategy

#### Error Boundary Component
```jsx
// components/common/ErrorBoundary.jsx
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send error to monitoring service
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h2>Something went wrong</h2>
          <p>We're sorry, but something unexpected happened.</p>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

#### API Error Handling
```jsx
// utils/errorHandler.js
export const handleApiError = (error) => {
  if (error.error?.code === 'VALIDATION_ERROR') {
    return {
      type: 'validation',
      message: 'Please check your input and try again.',
      details: error.error.details
    };
  }
  
  if (error.error?.code === 'AUTHENTICATION_FAILED') {
    return {
      type: 'auth',
      message: 'Please log in again.',
      action: 'redirect_to_login'
    };
  }
  
  if (error.error?.code === 'AUTHORIZATION_FAILED') {
    return {
      type: 'permission',
      message: 'You don\'t have permission to perform this action.'
    };
  }
  
  return {
    type: 'general',
    message: 'An unexpected error occurred. Please try again.'
  };
};
```

### 4.3 Loading States Management

#### Loading Component
```jsx
// components/common/LoadingSpinner.jsx
import React from 'react';

const LoadingSpinner = ({ size = 'medium', message = 'Loading...' }) => {
  return (
    <div className={`loading-spinner loading-spinner--${size}`}>
      <div className="spinner"></div>
      <p>{message}</p>
    </div>
  );
};

export default LoadingSpinner;
```

#### Loading States in Components
```jsx
// components/projects/ProjectList.jsx
import React from 'react';
import { useProjects } from '../../hooks/useProjects';
import LoadingSpinner from '../common/LoadingSpinner';
import ProjectCard from './ProjectCard';

const ProjectList = () => {
  const { projects, loading, error } = useProjects();

  if (loading) {
    return <LoadingSpinner message="Loading projects..." />;
  }

  if (error) {
    return <div className="error-message">{error}</div>;
  }

  return (
    <div className="project-list">
      {projects.map(project => (
        <ProjectCard key={project.id} project={project} />
      ))}
    </div>
  );
};

export default ProjectList;
```

---

## 5. UI/UX Implementation

### 5.1 Component Library Setup

#### Common Components
```jsx
// components/common/Button.jsx
import React from 'react';

const Button = ({ 
  children, 
  variant = 'primary', 
  size = 'medium', 
  disabled = false,
  loading = false,
  onClick,
  type = 'button'
}) => {
  return (
    <button
      type={type}
      className={`btn btn--${variant} btn--${size}`}
      disabled={disabled || loading}
      onClick={onClick}
    >
      {loading && <span className="btn__spinner"></span>}
      {children}
    </button>
  );
};

export default Button;
```

#### Form Components
```jsx
// components/common/Form.jsx
import React from 'react';

const Form = ({ children, onSubmit, className = '' }) => {
  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(e);
  };

  return (
    <form onSubmit={handleSubmit} className={`form ${className}`}>
      {children}
    </form>
  );
};

export default Form;
```

### 5.2 Responsive Design Strategy

#### CSS Grid Layout
```css
/* styles/layout.css */
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  padding: 1.5rem;
}

@media (max-width: 768px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    padding: 1rem;
  }
}

.sidebar {
  width: 250px;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  background: var(--sidebar-bg);
  transition: transform 0.3s ease;
}

@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
  }
  
  .sidebar--open {
    transform: translateX(0);
  }
}
```

### 5.3 Accessibility Implementation

#### Accessible Components
```jsx
// components/common/Modal.jsx
import React, { useEffect, useRef } from 'react';

const Modal = ({ isOpen, onClose, title, children }) => {
  const modalRef = useRef(null);

  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div 
      className="modal-overlay" 
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div 
        className="modal-content" 
        onClick={(e) => e.stopPropagation()}
        ref={modalRef}
      >
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button 
            className="modal-close"
            onClick={onClose}
            aria-label="Close modal"
          >
            ×
          </button>
        </div>
        <div className="modal-body">
          {children}
        </div>
      </div>
    </div>
  );
};

export default Modal;
```

---

## 6. Advanced Features

### 6.1 Real-time Updates (WebSocket)

#### WebSocket Service
```jsx
// services/websocketService.js
class WebSocketService {
  constructor() {
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.listeners = new Map();
  }

  connect(token) {
    const wsUrl = process.env.REACT_APP_WS_URL || 'ws://localhost:8000';
    this.ws = new WebSocket(`${wsUrl}?token=${token}`);

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };

    this.ws.onclose = () => {
      console.log('WebSocket disconnected');
      this.reconnect();
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  handleMessage(data) {
    const { type, payload } = data;
    const listeners = this.listeners.get(type) || [];
    listeners.forEach(callback => callback(payload));
  }

  subscribe(type, callback) {
    if (!this.listeners.has(type)) {
      this.listeners.set(type, []);
    }
    this.listeners.get(type).push(callback);
  }

  unsubscribe(type, callback) {
    const listeners = this.listeners.get(type) || [];
    const index = listeners.indexOf(callback);
    if (index > -1) {
      listeners.splice(index, 1);
    }
  }

  reconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        const token = localStorage.getItem('access_token');
        if (token) {
          this.connect(token);
        }
      }, 1000 * this.reconnectAttempts);
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
    }
  }
}

export const websocketService = new WebSocketService();
```

### 6.2 File Upload Interface

#### File Upload Component
```jsx
// components/files/FileUpload.jsx
import React, { useState, useRef } from 'react';
import { fileService } from '../../services/fileService';

const FileUpload = ({ onUploadComplete, projectId, taskId }) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const fileInputRef = useRef(null);

  const handleFileSelect = async (event) => {
    const files = Array.from(event.target.files);
    setUploading(true);
    setProgress(0);

    try {
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        await uploadFile(file, (progress) => {
          setProgress((i / files.length) * 100 + (progress / files.length));
        });
      }
      
      onUploadComplete();
      setProgress(100);
    } catch (error) {
      console.error('Upload failed:', error);
    } finally {
      setUploading(false);
      setProgress(0);
    }
  };

  const uploadFile = async (file, onProgress) => {
    const formData = new FormData();
    formData.append('file', file);
    if (projectId) formData.append('project_id', projectId);
    if (taskId) formData.append('task_id', taskId);

    await fileService.uploadFile(formData, onProgress);
  };

  return (
    <div className="file-upload">
      <input
        ref={fileInputRef}
        type="file"
        multiple
        onChange={handleFileSelect}
        style={{ display: 'none' }}
      />
      
      <button
        className="btn btn--secondary"
        onClick={() => fileInputRef.current.click()}
        disabled={uploading}
      >
        {uploading ? 'Uploading...' : 'Choose Files'}
      </button>
      
      {uploading && (
        <div className="upload-progress">
          <div 
            className="progress-bar"
            style={{ width: `${progress}%` }}
          ></div>
          <span>{Math.round(progress)}%</span>
        </div>
      )}
    </div>
  );
};

export default FileUpload;
```

---

## 7. Testing Strategy

### 7.1 Component Testing

#### Component Test Example
```jsx
// __tests__/components/LoginForm.test.jsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import LoginForm from '../../components/auth/LoginForm';

describe('LoginForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('renders login form', () => {
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  });

  it('submits form with valid data', async () => {
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    });
    
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /login/i }));
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });
  });

  it('shows validation errors for invalid data', async () => {
    render(<LoginForm onSubmit={mockOnSubmit} />);
    
    fireEvent.click(screen.getByRole('button', { name: /login/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
      expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    });
  });
});
```

### 7.2 Integration Testing

#### API Integration Test
```jsx
// __tests__/integration/auth.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from '../../contexts/AuthContext';
import LoginPage from '../../pages/auth/LoginPage';
import { authService } from '../../services/authService';

// Mock the auth service
jest.mock('../../services/authService');

describe('Authentication Integration', () => {
  beforeEach(() => {
    authService.login.mockClear();
  });

  it('handles successful login', async () => {
    const mockLoginResponse = {
      access_token: 'mock-token',
      user: { id: '1', email: 'test@example.com' }
    };
    
    authService.login.mockResolvedValue(mockLoginResponse);
    
    render(
      <BrowserRouter>
        <AuthProvider>
          <LoginPage />
        </AuthProvider>
      </BrowserRouter>
    );
    
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    });
    
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /login/i }));
    
    await waitFor(() => {
      expect(authService.login).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });
  });
});
```

---

## 8. Time Estimates and Risk Assessment

### 8.1 Time Estimates

| Phase | Components | Estimated Time | Priority |
|-------|------------|----------------|----------|
| 1 | Auth + Layout | 2-3 hours | CRITICAL |
| 2 | User + Project Management | 2-3 hours | HIGH |
| 3 | Task + Time Tracking | 2-3 hours | HIGH |
| 4 | File + Comments | 1-2 hours | MEDIUM |
| 5 | Notifications + Analytics | 1-2 hours | LOW |
| **Total** | **All Components** | **8-13 hours** | **-** |

### 8.2 Risk Assessment

#### High-Risk Items
1. **State Management Complexity**: Managing state across multiple services
   - **Mitigation**: Use established patterns (Context + Reducer)
   
2. **API Integration**: Handling multiple service endpoints
   - **Mitigation**: Centralized service layer with error handling
   
3. **Real-time Updates**: WebSocket implementation complexity
   - **Mitigation**: Start with polling, upgrade to WebSocket later

#### Medium-Risk Items
1. **Performance**: Large component trees and re-renders
   - **Mitigation**: Use React.memo, useMemo, useCallback
   
2. **Mobile Responsiveness**: Complex layouts on mobile
   - **Mitigation**: Mobile-first design approach

#### Low-Risk Items
1. **File Upload**: Large file handling
   - **Mitigation**: Chunked uploads and progress indicators
   
2. **Accessibility**: Screen reader compatibility
   - **Mitigation**: Use semantic HTML and ARIA labels

### 8.3 Success Criteria

#### Phase 1 Success Criteria
- [ ] Users can register and login successfully
- [ ] Authentication state is managed globally
- [ ] Basic layout and navigation work
- [ ] Protected routes function correctly

#### Phase 2 Success Criteria
- [ ] User profiles can be viewed and edited
- [ ] Projects can be created, viewed, and managed
- [ ] Project data is fetched from API correctly
- [ ] State updates trigger UI updates

#### Phase 3 Success Criteria
- [ ] Tasks can be created and assigned
- [ ] Task status can be updated
- [ ] Time tracking works
- [ ] Real-time updates function

#### Phase 4 Success Criteria
- [ ] Files can be uploaded and viewed
- [ ] Comments can be added to tasks
- [ ] Notifications are displayed
- [ ] Analytics dashboard shows data

---

## 9. Implementation Checklist

### Phase 1: Core Foundation
- [ ] Set up React project structure
- [ ] Implement authentication components
- [ ] Create layout and navigation
- [ ] Set up routing with React Router
- [ ] Implement global state management
- [ ] Create API service layer
- [ ] Write tests for auth components

### Phase 2: Core Business Logic
- [ ] Implement user management components
- [ ] Create project management components
- [ ] Set up project state management
- [ ] Implement project CRUD operations
- [ ] Add project filtering and search
- [ ] Write tests for project components

### Phase 3: Task Management
- [ ] Implement task components
- [ ] Create task state management
- [ ] Add task assignment functionality
- [ ] Implement time tracking components
- [ ] Create task board (Kanban) view
- [ ] Write tests for task components

### Phase 4: Supporting Features
- [ ] Implement file upload components
- [ ] Create comment system
- [ ] Add mention functionality
- [ ] Implement file preview
- [ ] Write tests for file and comment components

### Phase 5: Advanced Features
- [ ] Implement notification system
- [ ] Create analytics dashboard
- [ ] Add real-time updates
- [ ] Implement advanced filtering
- [ ] Write end-to-end tests

### Performance and UX
- [ ] Implement loading states
- [ ] Add error handling
- [ ] Optimize component performance
- [ ] Ensure mobile responsiveness
- [ ] Add accessibility features
- [ ] Implement progressive loading

---

## 10. Next Steps

1. **Start with Authentication**: Implement login/register components
2. **Set up Global State**: Create AuthContext and state management
3. **Build Layout**: Create main layout and navigation
4. **Implement Core Features**: User and project management
5. **Add Task Management**: Task creation and assignment
6. **Integrate Supporting Features**: File uploads and comments
7. **Add Advanced Features**: Notifications and analytics
8. **Optimize Performance**: Add caching and lazy loading
9. **Test Thoroughly**: Unit, integration, and e2e tests
10. **Deploy and Monitor**: Production deployment with monitoring

This frontend implementation plan provides a clear roadmap for building the React SPA that integrates seamlessly with your microservices backend. The component-driven approach ensures maintainability and reusability while the state management strategy handles the complexity of multiple service integrations. 