# React Frontend - Project Management System

## Overview

This is the React frontend for the Project Management System, built with TypeScript, modern React patterns, and optimized for production deployment.

## Tech Stack

- **React 18** with TypeScript
- **React Router** for navigation
- **React Query** for data fetching
- **Zustand** for state management
- **React Hook Form** with Zod validation
- **Tailwind CSS** for styling
- **Axios** for HTTP requests
- **Socket.io** for real-time updates

## Docker Setup

### Production Build

The production build uses a multi-stage Docker approach:

```bash
# Build and run production
docker-compose up frontend

# Or build manually
docker build -t frontend:prod ./frontend
```

**Features:**
- Multi-stage build for optimized image size
- Nginx for serving static files
- Security headers and rate limiting
- Health checks
- Non-root user execution

### Development Build

For local development with hot reloading:

```bash
# Run development environment
docker-compose --profile dev up frontend-dev

# Or build manually
docker build -f Dockerfile.dev -t frontend:dev ./frontend
```

**Features:**
- Hot reloading with volume mounts
- Development server on port 3001
- Source code mounted for live editing

## File Structure

```
frontend/
├── public/                 # Static assets
├── src/
│   ├── components/         # Reusable components
│   │   ├── auth/          # Authentication components
│   │   ├── projects/      # Project management
│   │   ├── tasks/         # Task management
│   │   ├── time/          # Time tracking
│   │   ├── analytics/     # Analytics dashboard
│   │   └── common/        # Shared components
│   ├── pages/             # Page components
│   ├── services/          # API services
│   ├── utils/             # Utility functions
│   ├── hooks/             # Custom React hooks
│   ├── types/             # TypeScript types
│   ├── App.tsx            # Main app component
│   └── index.tsx          # Entry point
├── Dockerfile             # Production Dockerfile
├── Dockerfile.dev         # Development Dockerfile
├── .dockerignore          # Docker ignore file
├── nginx.conf             # Nginx configuration
├── package.json           # Dependencies and scripts
└── README.md              # This file
```

## Development Workflow

### Local Development

1. **Start development environment:**
   ```bash
   docker-compose --profile dev up frontend-dev
   ```

2. **Access the application:**
   - Frontend: http://localhost:3001
   - API Gateway: http://localhost:8000

3. **Code changes** will automatically reload

### Production Deployment

1. **Build and start production:**
   ```bash
   docker-compose up frontend
   ```

2. **Access the application:**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8000

## Environment Variables

### Required Environment Variables

```bash
REACT_APP_API_URL=http://localhost:8000    # API Gateway URL
REACT_APP_WS_URL=ws://localhost:8000       # WebSocket URL
```

### Development Environment Variables

```bash
CHOKIDAR_USEPOLLING=true                   # Enable file watching
WATCHPACK_POLLING=true                     # Enable webpack polling
```

## Nginx Configuration

The production build uses Nginx with the following features:

- **Static file serving** with caching
- **API proxy** to backend services
- **WebSocket proxy** for real-time features
- **Security headers** (CSP, XSS protection, etc.)
- **Rate limiting** for API endpoints
- **Gzip compression** for better performance
- **SPA routing** support (fallback to index.html)

## Security Features

- **Content Security Policy** (CSP) headers
- **XSS Protection** headers
- **Frame Options** to prevent clickjacking
- **Rate limiting** on API endpoints
- **Non-root user** execution in containers
- **Secure headers** for all responses

## Performance Optimizations

- **Multi-stage Docker builds** for smaller images
- **Static file caching** with long expiration
- **Gzip compression** for text-based assets
- **Code splitting** with React.lazy()
- **Tree shaking** for unused code elimination
- **Image optimization** and lazy loading

## Health Checks

The application includes health checks:

- **Production**: `/health` endpoint returns 200 OK
- **Development**: Root endpoint check
- **Docker**: Automatic health monitoring

## Troubleshooting

### Common Issues

1. **Build fails:**
   ```bash
   # Clear Docker cache
   docker system prune -a
   # Rebuild
   docker-compose build --no-cache frontend
   ```

2. **Hot reload not working:**
   ```bash
   # Check volume mounts
   docker-compose --profile dev up frontend-dev
   ```

3. **API connection issues:**
   ```bash
   # Verify API Gateway is running
   docker-compose ps api-gateway
   ```

### Logs

```bash
# View frontend logs
docker-compose logs frontend

# View development logs
docker-compose --profile dev logs frontend-dev
```

## Best Practices

1. **Use TypeScript** for all new code
2. **Follow React patterns** (hooks, functional components)
3. **Implement proper error boundaries**
4. **Use React Query** for data fetching
5. **Optimize bundle size** with code splitting
6. **Test components** with React Testing Library
7. **Follow accessibility** guidelines (ARIA, semantic HTML)
8. **Use proper loading states** and error handling

## Contributing

1. Follow the established code structure
2. Add TypeScript types for new features
3. Include proper error handling
4. Test your changes locally
5. Update documentation as needed 