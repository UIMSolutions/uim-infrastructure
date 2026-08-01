# uim-openstack-service

OpenStack service facade implemented with D and vibe.d using Clean and Hexagonal architecture.

The service provides:

- HTTP controller endpoints for OpenStack project and server operations.
- MVC HTML web dashboard for interactive rendering and actions.
- Deployment compatibility for Docker, Podman, Cloud Foundry, and Kubernetes.

## Endpoints

- GET /health
- GET /api/v1/projects
- GET /api/v1/servers?projectId=<id>&region=<region>
- POST /api/v1/server-actions
- GET /
- GET /web

## Architecture

```text
openstack/
├── source/
│   ├── app.d
│   └── uim/infrastructure/openstack/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── project.d
│       │   │   └── server.d
│       │   └── ports/
│       │       └── openstack_gateway.d
│       ├── application/
│       │   ├── dto/
│       │   │   └── reboot_server_command.d
│       │   └── usecases/
│       │       ├── list_projects.d
│       │       ├── list_servers.d
│       │       └── reboot_server.d
│       └── infrastructure/
│           ├── config/settings.d
│           └── http/
│               ├── clients/openstack_gateway.d
│               ├── controllers/
│               │   ├── openstack_api_controller.d
│               │   └── web_controller.d
│               └── views/dashboard_view.d
├── Dockerfile
├── Containerfile
├── manifest.yml
└── k8s/
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| PORT | 8080 | HTTP port |
| BIND_ADDRESS | 0.0.0.0 | Bind address |
| OPENSTACK_IDENTITY_URL | empty | Keystone endpoint base URL |
| OPENSTACK_COMPUTE_URL | empty | Nova endpoint base URL |
| OPENSTACK_TOKEN | empty | Default token (optional for local fallback mode) |
| OPENSTACK_DEFAULT_REGION | RegionOne | Region default |

If identity/compute URLs are not configured, the service returns local fallback data for development.

## Build and Run

- cd openstack
- dub build
- ./uim-openstack-service

## Docker

- docker build -t uim-openstack-service .
- docker run -p 8080:8080 -e OPENSTACK_IDENTITY_URL=https://keystone.example.com -e OPENSTACK_COMPUTE_URL=https://nova.example.com uim-openstack-service

## Podman

- podman build -t uim-openstack-service .
- podman run -p 8080:8080 -e OPENSTACK_IDENTITY_URL=https://keystone.example.com -e OPENSTACK_COMPUTE_URL=https://nova.example.com uim-openstack-service

## Cloud Foundry

- cf push -f manifest.yml

## Kubernetes

- kubectl apply -f k8s/namespace.yaml
- kubectl apply -f k8s/configmap.yaml
- kubectl apply -f k8s/deployment.yaml
- kubectl apply -f k8s/service.yaml
