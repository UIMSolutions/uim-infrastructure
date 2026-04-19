# UIM Infobox Service

A cloud-native CI/CD service inspired by [SAP InfraBox](https://github.com/SAP/InfraBox), built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture.

## Features

- **Projects**: Manage CI/CD projects linked to git repositories
- **Builds**: Trigger and track build executions with multiple trigger types (manual, push, pull_request, schedule, API)
- **Jobs**: Define build tasks with types (docker, docker_compose, docker_image, git, workflow), resource limits, dependencies, and environment variables
- **Secrets**: Manage encrypted project secrets for use in jobs
- **Workflows**: DAG-based job execution with dependency resolution

## Architecture

- **Domain**: Project, Build, Job, and Secret entities; repository port interfaces.
- **Application**: Use cases that enforce business rules (CRUD for projects/secrets, trigger/list/get builds, create/list/get jobs).
- **Infrastructure**: HTTP adapter (vibe.d routes) and in-memory repository adapters.

### Layer mapping

- Domain: `source/uim/infrastructure/infobox/domain`
- Application: `source/uim/infrastructure/infobox/application`
- Infrastructure: `source/uim/infrastructure/infobox/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repositories are outbound adapters.

## API

### Health

- `GET /health`

### Projects

- List all: `GET /v1/projects`
- Get by ID: `GET /v1/projects/<id>`
- Create: `POST /v1/projects` (JSON body)
- Delete: `DELETE /v1/projects/<id>`

Create project JSON body example:

```json
{
  "name": "my-app",
  "description": "My CI/CD project",
  "repository": "https://git.example.com/app.git",
  "branch": "main"
}
```

### Builds

- Trigger build: `POST /v1/projects/<id>/builds`
- List builds: `GET /v1/projects/<id>/builds`
- Get build: `GET /v1/builds/<id>`

Trigger build JSON body example:

```json
{
  "triggeredBy": "alice",
  "commitSha": "abc123def",
  "branch": "feature-branch",
  "trigger": "push"
}
```

### Jobs

- Create job: `POST /v1/builds/<id>/jobs`
- List jobs: `GET /v1/builds/<id>/jobs`
- Get job: `GET /v1/jobs/<id>`

Create job JSON body example:

```json
{
  "projectId": "proj-1",
  "name": "compile",
  "type": "docker",
  "dockerFile": "Dockerfile",
  "command": "dub build --build=release",
  "buildContext": ".",
  "cpuMillis": 2000,
  "memoryMb": 4096,
  "timeoutSeconds": 600,
  "dependencies": ["checkout"],
  "environment": [
    { "name": "CI", "value": "true", "isSecret": false },
    { "name": "TOKEN", "value": "secret-ref", "isSecret": true }
  ]
}
```

### Secrets

- Create secret: `POST /v1/projects/<id>/secrets`
- List secrets: `GET /v1/projects/<id>/secrets`
- Delete secret: `DELETE /v1/secrets/<id>`

Create secret JSON body example:

```json
{
  "name": "DB_PASSWORD",
  "value": "super-secret-value"
}
```

## Run locally

```bash
cd infobox
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd infobox
docker build -t uim-infobox-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-infobox-service uim-infobox-service:latest
```

## Podman

Build:

```bash
cd infobox
podman build -f Containerfile -t uim-infobox-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-infobox-service uim-infobox-service:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Access from cluster tooling:

```bash
kubectl -n uim-infobox port-forward service/uim-infobox-service 8080:80
```

## Test

```bash
cd infobox
dub test
```
