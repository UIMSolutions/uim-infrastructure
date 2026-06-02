# uim-archer-service

An Archer-like endpoint catalog service inspired by SAP Archer, built with D and vibe.d using clean plus hexagonal architecture.

## What it provides

- Service catalog for private or public services
- Endpoint management for consuming service entries from tenant networks
- Archer-like API shape for service and endpoint resources
- In-memory adapters for rapid local development and testing

## API overview

- GET / - Version discovery payload with capabilities
- GET /health - Health status
- GET /service - List services (supports project_id, tags, tags-any, not-tags, not-tags-any)
- POST /service - Create service
- GET /service/{service_id} - Service details
- PUT /service/{service_id} - Update service
- DELETE /service/{service_id}?cascade=true - Delete service
- GET /service/{service_id}/endpoints - List service consumer endpoints
- PUT /service/{service_id}/accept_endpoints - Accept endpoints by endpoint_ids and or project_ids
- PUT /service/{service_id}/reject_endpoints - Reject endpoints by endpoint_ids and or project_ids
- GET /endpoint - List endpoints (supports project_id, tags, tags-any, not-tags, not-tags-any)
- POST /endpoint - Create endpoint
- GET /endpoint/{endpoint_id} - Endpoint details
- PUT /endpoint/{endpoint_id} - Update endpoint
- DELETE /endpoint/{endpoint_id} - Delete endpoint
- GET /rbac-policies - List RBAC policies
- POST /rbac-policies - Create RBAC policy
- GET /rbac-policies/{rbac_policy_id} - RBAC policy details
- PUT /rbac-policies/{rbac_policy_id} - Update RBAC policy
- DELETE /rbac-policies/{rbac_policy_id} - Delete RBAC policy
- GET /quotas - List quotas (supports project_id)
- GET /quotas/defaults - Get quota defaults
- GET /quotas/{project_id} - Get project quota
- PUT /quotas/{project_id} - Update project quota
- DELETE /quotas/{project_id} - Reset project quota
- GET /agents - List registered agents
- GET /agents/{agent_host} - Agent details

## Architecture

source/
  uim/infrastructure/archer/
    domain/
      entities/
      ports/repositories/
    application/
      dto/
      usecases/
    infrastructure/
      http/controllers/
      persistence/memory/

- Domain layer keeps business entities and stable interfaces
- Application layer encapsulates use cases and command DTOs
- Infrastructure layer exposes adapters for HTTP and persistence

## Build and run locally

```bash
dub build
./uim-archer-service
```

Run on a custom bind address and port:

```bash
BIND_ADDRESS=0.0.0.0 PORT=9312 ./uim-archer-service
```

## Docker and Podman

Build image:

```bash
docker build -t uim-archer-service .
podman build -t uim-archer-service .
```

Run image:

```bash
docker run -p 9312:9312 uim-archer-service
podman run -p 9312:9312 uim-archer-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Notes

- This implementation focuses on Archer-like service, endpoint, RBAC, quota, and agent resources.
- OpenStack Keystone and Neutron integrations are intentionally left as future adapters.
- Persistence is in-memory by design for a lightweight development baseline.
