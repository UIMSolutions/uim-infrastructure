# UIM Jenkins Service

A CI/CD pipeline management service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture.

## Architecture

- **Domain**: Pipeline and Build entities, repository port interfaces.
- **Application**: Use cases that enforce business rules (create/list/get/delete pipelines, trigger/list/get builds).
- **Infrastructure**: HTTP adapter (vibe.d routes) and in-memory repository adapters.

### Layer mapping

- Domain: `source/uim/infrastructure/jenkins/domain`
- Application: `source/uim/infrastructure/jenkins/application`
- Infrastructure: `source/uim/infrastructure/jenkins/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repositories are outbound adapters.

## API

### Health

- `GET /health`

### Pipelines

- List all: `GET /v1/pipelines`
- Get by ID: `GET /v1/pipelines/<id>`
- Create: `POST /v1/pipelines` (JSON body)
- Delete: `DELETE /v1/pipelines/<id>`

Create pipeline JSON body example:

```json
{
  "name": "build-app",
  "description": "Build and test the application",
  "repository": "https://git.example.com/app.git",
  "branch": "main",
  "stages": [
    { "name": "compile", "command": "dub build", "timeoutSeconds": 300 },
    { "name": "test", "command": "dub test", "timeoutSeconds": 600 }
  ]
}
```

### Builds

- Trigger build: `POST /v1/pipelines/<id>/builds` (optional JSON: `{ "triggeredBy": "user" }`)
- List builds: `GET /v1/pipelines/<id>/builds`
- Get build: `GET /v1/builds/<id>`

## Run locally

```bash
cd jenkins
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd jenkins
docker build -t uim-jenkins-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-jenkins-service uim-jenkins-service:latest
```

## Podman

Build:

```bash
cd jenkins
podman build -f Containerfile -t uim-jenkins-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-jenkins-service uim-jenkins-service:latest
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
kubectl -n uim-jenkins port-forward service/uim-jenkins-service 8080:80
```

## Test

```bash
cd jenkins
dub test
```
