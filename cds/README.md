# uim-cds-service

A CDS-like microservice built with **D** and **vibe.d** following **Clean** and **Hexagonal** architecture.

It provides:
- JSON HTTP controllers for machine clients.
- MVC-style HTML pages for human users.
- Packaging/deployment compatibility for Docker, Podman, Cloud Foundry, and Kubernetes.

## Project layout

```text
cds/
├── dub.sdl
├── Dockerfile
├── Containerfile
├── manifest.yml
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Nafv4.md
├── UML.md
└── source/
    ├── app.d
    └── uim/infrastructure/cds_service/
        ├── domain/
        │   ├── entities/cds_definition.d
        │   └── ports/repositories/cds_definition_repository.d
        ├── application/
        │   ├── dto/definition_command.d
        │   └── usecases/
        │       ├── create_definition.d
        │       ├── list_definitions.d
        │       ├── get_definition.d
        │       └── delete_definition.d
        └── infrastructure/
            ├── persistence/memory/cds_definition_repository.d
            └── http/
                ├── controllers/
                │   ├── api_controller.d
                │   └── web_controller.d
                └── views/html_renderer.d
```

## API endpoints

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/health` | Service health check |
| `GET` | `/v1/definitions` | List all CDS definitions |
| `POST` | `/v1/definitions` | Create a definition |
| `GET` | `/v1/definitions/<id>` | Fetch one definition |
| `DELETE` | `/v1/definitions/<id>` | Remove one definition |

### Example create payload

```json
{
  "namespace": "uim.catalog",
  "name": "Books",
  "modelVersion": "1.0.0",
  "deprecated": false,
  "fields": [
    { "name": "ID", "type": "UUID", "key": true, "nullable": false },
    { "name": "title", "type": "String", "nullable": false },
    { "name": "createdAt", "type": "Timestamp", "nullable": true }
  ]
}
```

## MVC HTML pages

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/` | Definition catalog |
| `GET` | `/definitions` | Definition catalog |
| `GET` | `/definitions/new` | Create form |
| `POST` | `/definitions/new` | Submit create form |
| `GET` | `/definitions/<id>` | Definition detail + CDS source |

Field input format in the form:

```text
name:type[:key][:required]
```

Example:

```text
ID:UUID:key:required
title:String:required
createdAt:Timestamp
```

## Run locally

```bash
cd cds
dub run
```

Environment variables:

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | HTTP listen port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `PID_FILE` | `/var/run/uim-cds-service.pid` | Optional PID file path |
| `CDS_DEFAULT_NAMESPACE` | `uim.cds` | Default namespace in MVC form |

## Docker

```bash
docker build -t uim-cds-service .
docker run --rm -p 8080:8080 uim-cds-service
```

## Podman

```bash
podman build -t uim-cds-service .
podman run --rm -p 8080:8080 uim-cds-service
```

## Cloud Foundry

```bash
cf push -f manifest.yml
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Architecture notes

- **Domain** contains entities and repository ports only.
- **Application** contains use-cases and command DTOs.
- **Infrastructure** provides adapters: HTTP API, MVC web UI, and in-memory persistence.
- Dependencies point inward only (infrastructure -> application -> domain).
