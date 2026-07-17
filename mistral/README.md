# UIM Mistral Service

A Mistral-inspired workflow orchestration service built with D and vibe.d, following clean and hexagonal architecture principles.

## Reference Material

- Product and service behavior: https://docs.openstack.org/mistral/latest/
- API style and resources: https://docs.openstack.org/api-ref/workflow/v2/
- Upstream implementation reference: https://github.com/openstack/mistral

## Architecture

This service is organized into four layers:

- Domain: entities and repository contracts for workflows and executions
- Application: use cases and command DTOs that model orchestration operations
- Infrastructure: HTTP controller and in-memory persistence adapters
- Composition: entrypoint wiring in `source/app.d`

## Implemented API Subset

Base API: `/v2`

- `GET /health`
- `GET /v2`

### Workflows

- `GET /v2/workflows`
- `GET /v2/workflows/{id}`
- `POST /v2/workflows`
- `PUT /v2/workflows/{id}`
- `DELETE /v2/workflows/{id}`

### Executions

- `GET /v2/executions`
- `GET /v2/executions/{id}`
- `POST /v2/executions`
- `DELETE /v2/executions/{id}`

### Tasks

- `GET /v2/tasks`
- `GET /v2/tasks/{id}`

### Action Executions

- `GET /v2/action_executions`
- `GET /v2/action_executions/{id}`
- `POST /v2/action_executions`

### Query Filters and Pagination

List endpoints support Mistral-style query parameters:

- `limit` and `marker` for pagination
- `name`, `namespace`, `tags` on workflows
- `workflow_name`, `workflow_id`, `project_id`, `state` on executions
- `workflow_execution_id`, `name`, `state` on tasks
- `task_execution_id`, `workflow_name`, `state` on action executions

## Build and Run

### Local

```bash
cd mistral
dub build
./uim-mistral-service
```

### Docker

```bash
cd mistral
docker build -t uim-mistral-service:latest .
docker run --rm -p 8080:8080 uim-mistral-service:latest
```

### Podman

```bash
cd mistral
podman build -t uim-mistral-service:latest -f Containerfile .
podman run --rm -p 8080:8080 uim-mistral-service:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Example Requests

Create a workflow:

```bash
curl -s -X POST http://localhost:8080/v2/workflows \
  -H 'Content-Type: application/json' \
  -d '{
    "name":"hello_world",
    "definition":"version: \"2.0\"\\nhello_world:\\n  type: direct\\n  tasks:\\n    greet:\\n      action: std.echo output=\"Hello\"",
    "description":"Sample workflow"
  }' | jq
```

Start an execution:

```bash
curl -s -X POST http://localhost:8080/v2/executions \
  -H 'Content-Type: application/json' \
  -d '{
    "workflow_name":"hello_world",
    "input": {"name":"UI Manufaktur"}
  }' | jq
```

## Notes

- The current persistence adapter is in-memory and resets on restart.
- Responses include OpenStack-style metadata headers for request tracing and API version signaling.
- The implementation intentionally focuses on a practical Mistral-compatible subset for orchestration workflows.
