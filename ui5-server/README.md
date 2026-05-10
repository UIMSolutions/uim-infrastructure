# UIM UI5 Server Service

Cloud-native UI5 development server service inspired by [SAP UI5 Server](https://github.com/SAP/ui5-server), built with **vibe.d** and **D** using a combination of clean and hexagonal architecture.

## Overview

This service provides server capabilities for UI5 project development, modeling the core concepts of the SAP UI5 Server:

- **Server Management** - Create, configure, and manage development server instances (HTTP/HTTPS/H2)
- **Middleware Pipeline** - Register and order middleware (CSP, compression, CORS, discovery, serveResources, testRunner, serveThemes, versionInfo, nonReadRequests, serveIndex, custom)
- **Resource Serving** - Upload, serve, list, and manage project resources with content-type resolution
- **Project Management** - Register UI5 projects (application, library, themeLibrary, module) with dependencies
- **Content Security Policy** - CSP report collection and retrieval at `/.ui5/csp/csp-reports.json`
- **Discovery Endpoint** - Lists registered servers, middleware, and projects
- **Directory Index** - Browse resource directory listings
- **SSL/TLS Support** - Certificate configuration for HTTPS and HTTP/2 servers

## Architecture

```
Clean + Hexagonal Architecture

Domain Layer (entities + port interfaces)
    |
Application Layer (use cases + DTOs)
    |
Infrastructure Layer
    +-- Inbound:  HTTP Controller (vibe.d REST API)
    +-- Outbound: In-Memory Repositories (thread-safe with Mutex)
    |
Composition Root (app.d wires everything)
```

## API Endpoints

### Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |

### Server Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/servers` | Create a server configuration |
| GET | `/api/v1/servers` | List all servers |
| GET | `/api/v1/servers/{id}` | Get server by ID |
| PATCH | `/api/v1/servers/{id}` | Update server status (stopped, starting, running, stopping, error) |
| DELETE | `/api/v1/servers/{id}` | Delete a server |

### Middleware Pipeline
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/middleware` | Register middleware |
| GET | `/api/v1/middleware` | List all middleware (ordered by execution order) |
| DELETE | `/api/v1/middleware/{name}` | Remove middleware |

### Resource Serving
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/resources` | Upload a resource |
| GET | `/api/v1/resources?path=/dir` | List resources in a directory |
| DELETE | `/api/v1/resources/{path}` | Delete a resource |
| GET | `/resources/{path}` | Serve a resource (returns actual content) |

### Project Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/projects` | Register a UI5 project |
| GET | `/api/v1/projects` | List all projects |
| DELETE | `/api/v1/projects/{id}` | Delete a project |

### CSP and Discovery
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/.ui5/csp/csp-reports.json` | Get CSP violation reports |
| GET | `/discovery` | Discovery endpoint (servers, middleware, projects) |
| GET | `/api/v1/directory/{path}` | Browse directory listing |

## Example Usage

### 1. Create a Server Configuration
```bash
curl -X POST http://localhost:8080/api/v1/servers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "dev-server",
    "port": 3000,
    "host": "localhost",
    "protocol": "http",
    "acceptRemoteConnections": false,
    "changePortIfInUse": true,
    "simpleIndex": false,
    "middlewareNames": ["csp", "compression", "cors", "serveResources", "serveIndex"]
  }'
```

### 2. Register Middleware
```bash
# CSP middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "csp", "type": "csp", "order": 1, "enabled": true, "config": {"sendSAPTargetCSP": "true"}}'

# Compression middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "compression", "type": "compression", "order": 2, "enabled": true}'

# CORS middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "cors", "type": "cors", "order": 3, "enabled": true}'

# Resource serving middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "serveResources", "type": "serveResources", "order": 5, "enabled": true}'

# Theme compilation middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "serveThemes", "type": "serveThemes", "order": 7, "enabled": true}'

# Directory index middleware
curl -X POST http://localhost:8080/api/v1/middleware \
  -H "Content-Type: application/json" \
  -d '{"name": "serveIndex", "type": "serveIndex", "order": 10, "enabled": true}'
```

### 3. Register a UI5 Project
```bash
curl -X POST http://localhost:8080/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-ui5-app",
    "type": "application",
    "rootPath": "/webapp",
    "version": "1.0.0",
    "namespace": "com.example.myapp",
    "dependencies": [
      {"name": "sap.ui.core", "version": "1.120.0"},
      {"name": "sap.m", "version": "1.120.0"}
    ]
  }'
```

### 4. Upload Resources
```bash
# Upload an HTML file
curl -X POST http://localhost:8080/api/v1/resources \
  -H "Content-Type: application/json" \
  -d '{
    "path": "/webapp/index.html",
    "contentType": "text/html",
    "content": "<!DOCTYPE html><html><head><title>My App</title></head><body></body></html>"
  }'

# Upload a JS controller
curl -X POST http://localhost:8080/api/v1/resources \
  -H "Content-Type: application/json" \
  -d '{
    "path": "/webapp/controller/App.controller.js",
    "contentType": "application/javascript",
    "content": "sap.ui.define([\"sap/ui/core/mvc/Controller\"], function(Controller) { return Controller.extend(\"myapp.controller.App\", {}); });"
  }'
```

### 5. Serve a Resource
```bash
curl http://localhost:8080/resources/webapp/index.html
```

### 6. List Resources in a Directory
```bash
curl "http://localhost:8080/api/v1/resources?path=/webapp"
```

### 7. Browse Directory
```bash
curl http://localhost:8080/api/v1/directory/webapp
```

### 8. Discovery
```bash
curl http://localhost:8080/discovery
```

### 9. CSP Reports
```bash
curl http://localhost:8080/.ui5/csp/csp-reports.json
```

### 10. Update Server Status
```bash
curl -X PATCH http://localhost:8080/api/v1/servers/{id} \
  -H "Content-Type: application/json" \
  -d '{"status": "running"}'
```

## Build and Run

### Local
```bash
cd ui5-server
dub build
./uim-ui5-server-service
```

### Docker
```bash
docker build -t uim-ui5-server-service .
docker run -p 8080:8080 uim-ui5-server-service
```

### Podman
```bash
podman build -t uim-ui5-server-service -f Containerfile .
podman run -p 8080:8080 uim-ui5-server-service
```

### Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Project Structure

```
ui5-server/
  dub.sdl
  Dockerfile
  Containerfile
  README.md
  k8s/
    namespace.yaml
    configmap.yaml
    deployment.yaml
    service.yaml
  source/
    app.d                                # Composition root
    uim/infrastructure/ui5server/
      domain/
        entities/
          server.d                       # Server (protocol, port, host, SSL, status)
          middleware.d                    # Middleware (type enum: csp, compression, cors, ...)
          resource.d                     # Resource (path, content, contentType, size)
          project.d                      # Project (application, library, themeLibrary, module)
          csp_policy.d                   # CspPolicy + CspReport
          ssl_certificate.d              # SSL certificate configuration
          theme.d                        # Theme with LESS source compilation
          version_info.d                 # VersionInfo with library details
        ports/
          repositories/
            server.d                     # IServerRepository
            middleware.d                 # IMiddlewareRepository
            resource.d                   # IResourceRepository
            project.d                    # IProjectRepository
            csp_report.d                 # ICspReportRepository
      application/
        dtos/
          server.d                       # Server DTOs
          middleware.d                   # Middleware DTOs
          resource.d                     # Resource + DirectoryListing DTOs
          project.d                      # Project DTOs
          csp.d                          # CSP policy + report DTOs
        usecases/
          create_server.d
          get_server.d
          list_servers.d
          delete_server.d
          update_server_status.d
          register_middleware.d
          list_middleware.d
          remove_middleware.d
          upload_resource.d
          serve_resource.d
          list_resources.d
          delete_resource.d
          create_project.d
          list_projects.d
          delete_project.d
          get_csp_reports.d
      infrastructure/
        adapters/
          http/
            controller.d                 # UI5ServerController with all routes
          inmemory/
            server_repository.d
            middleware_repository.d       # With ordered retrieval
            resource_repository.d        # With directory listing
            project_repository.d
            csp_report_repository.d
```

## UI5 Server Concepts Modeled

- **Server Lifecycle** - Create, start, stop, and manage development server instances
- **Middleware Pipeline** - Ordered chain of middleware matching UI5 Server standard middleware (CSP, compression, CORS, discovery, serveResources, testRunner, serveThemes, versionInfo, nonReadRequests, serveIndex)
- **Resource Serving** - Upload and serve project files with proper content types
- **Project Registration** - Track UI5 projects with type classification and dependency management
- **Content Security Policy** - CSP report collection endpoint at `/.ui5/csp/csp-reports.json`
- **Discovery** - Service discovery listing all registered servers, middleware, and projects
- **Directory Browsing** - Browse resource directories with file metadata
- **SSL/TLS** - Certificate management for HTTPS/H2 protocol support
- **Custom Middleware** - Extensibility via custom middleware type registration

## License

Apache-2.0
