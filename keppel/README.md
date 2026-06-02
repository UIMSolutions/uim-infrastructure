# uim-keppel-service

A container image registry metadata service inspired by [SAPCC Keppel](https://github.com/sapcc/keppel), built with **D** and **vibe.d** using clean + hexagonal architecture.

## What it does

Implements a Keppel-like control plane for repositories and tags with OCI-style discovery endpoints:

| Capability | Endpoint |
|---|---|
| Health check | `GET /health` |
| Registry ping | `GET /v2/` |
| Catalog | `GET /v2/_catalog` |
| Tags list | `GET /v2/{repository}/tags/list` |
| Get manifest | `GET /v2/{repository}/manifests/{reference}` |
| Put manifest | `PUT /v2/{repository}/manifests/{reference}` |
| Get blob | `GET /v2/{repository}/blobs/{digest}` |
| Put blob | `PUT /v2/{repository}/blobs/{digest}` |
| Repository CRUD | `/v1/repositories...` |
| Tag upsert/delete | `/v1/repositories/{name}/tags...` |

This service now supports a persistent file-backed repository adapter by default, while still allowing an in-memory mode for local experiments.

## API examples

### Create repository

```json
POST /v1/repositories
{
  "name": "customer/audit-agent",
  "project_id": "p-1000",
  "visibility": "private"
}
```

### Add or update tag metadata

```json
POST /v1/repositories/customer/audit-agent/tags
{
  "tag": "1.4.2",
  "digest": "sha256:6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d",
  "size_bytes": 73482112,
  "media_type": "application/vnd.oci.image.manifest.v1+json"
}
```

### OCI-style tag listing

```json
GET /v2/customer/audit-agent/tags/list
```

## Architecture

```text
source/
└── uim/infrastructure/keppel/
    ├── domain/
    │   ├── entities/         # Repository, ImageTag
    │   └── ports/
    │       └── repositories/ # IRegistryCatalogRepository
    ├── application/
    │   ├── dto/              # Commands
    │   └── usecases/         # One class per use case
    └── infrastructure/
        ├── http/
        │   └── controllers/  # KeppelController (vibe.d adapter)
        └── persistence/
            └── memory/       # InMemoryRegistryCatalogRepository
```

## Run locally

```bash
dub build
./uim-keppel-service
```

Default binding:

- `PORT=9312`
- `BIND_ADDRESS=0.0.0.0`
- `PERSISTENCE_BACKEND=file` (or `memory`)
- `CATALOG_DB_FILE=.keppel/catalog.json`

## Docker / Podman

```bash
# Docker
docker build -t uim-keppel-service .
docker run -p 9312:9312 uim-keppel-service

# Podman
podman build -t uim-keppel-service -f Containerfile .
podman run -p 9312:9312 uim-keppel-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Tests

```bash
dub test
```

Tests include:

- unit tests for repository/tag use cases
- OCI manifest/blob use case tests
- integration-style persistence test for file-backed adapter reloading state

## Smoke Script

Run an end-to-end OCI smoke check against a running service:

```bash
chmod +x scripts/smoke-oci.sh
./scripts/smoke-oci.sh
```

Optional environment overrides:

- `BASE_URL` (default `http://127.0.0.1:9312`)
- `REPO` (default `demo/smoke`)
- `TAG` (default `v1`)

## CI JUnit Smoke Script

Run smoke checks with JUnit XML output for CI systems:

```bash
chmod +x scripts/smoke-oci-ci.sh
./scripts/smoke-oci-ci.sh
```

By default it writes report output to:

- `./reports/keppel-smoke.xml`

Optional environment overrides:

- `JUNIT_FILE` (custom report path)
- `BASE_URL`, `REPO`, `TAG`
