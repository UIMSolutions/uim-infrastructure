# NAFv4 - Architecture Mapping for uim-openstack-service

## 1. Capability View

- Project inventory capability from OpenStack identity service.
- Server inventory and reboot capability from OpenStack compute service.
- Human interaction capability through MVC-rendered operations console.

## 2. Operational View

- Stateless process on HTTP port configured by PORT.
- Northbound interfaces:
  - JSON APIs under /api/v1
  - HTML dashboard under / and /web
- Southbound integrations:
  - Keystone-like identity API
  - Nova-like compute API

## 3. Service-Oriented View

- Inbound adapters:
  - OpenStackApiController
  - WebController
- Application services:
  - ListProjectsUseCase
  - ListServersUseCase
  - RebootServerUseCase
- Outbound port:
  - IOpenStackGateway
- Outbound adapter:
  - OpenStackGateway

## 4. Resource View

- OCI image runtime for Docker and Podman.
- Cloud Foundry app manifest for PaaS runtime.
- Kubernetes deployment with probes and resource limits.

## 5. Security View

- Token-based authentication pass-through via X-Auth-Token or Bearer token.
- Service does not persist tokens.
- Endpoint URLs and token are environment-driven.

## 6. Standards View

- REST over HTTP with JSON payloads.
- HTML5 rendering for web console.
- Deployment standards:
  - OCI containers
  - Cloud Foundry manifest
  - Kubernetes manifests
