# uim-manila-service

A Manila-inspired shared filesystem microservice built with D and vibe.d, structured around Clean Architecture and Hexagonal Architecture.

The service does not implement the full OpenStack Manila API surface. It focuses on the core shared filesystem lifecycle that most Manila deployments expose first: share types, shares, snapshots, and quota reporting, while now aligning more closely with OpenStack envelope and header conventions.

## Architecture

```
manila/
└── source/
    ├── app.d
    └── uim/infrastructure/manila/
        ├── domain/
        │   ├── entities/
        │   │   ├── share_type.d
        │   │   ├── share.d
        │   │   ├── share_snapshot.d
        │   │   └── quota_set.d
        │   └── ports/repositories/
        ├── application/
        │   ├── dto/manila_command.d
        │   └── usecases/
        └── infrastructure/
            ├── http/controllers/manila.d
            └── persistence/memory/
```

## HTTP API

| Method | Path | Description |
|---|---|---|
| GET | /health | Liveness and readiness probe |
| GET | /v1/share-types | List available share types |
| GET | /v1/shares | List all shares, optional `project_id` filter |
| POST | /v1/shares | Create a share |
| GET | /v1/shares/{id} | Get one share |
| DELETE | /v1/shares/{id} | Delete a share and its snapshots |
| GET | /v1/snapshots | List all snapshots, optional `project_id` filter |
| POST | /v1/snapshots | Create a snapshot from a share |
| GET | /v1/quotas/{project_id} | Report quota usage for one project |

## OpenStack Compatibility Extensions

- Response headers include:
  - `OpenStack-API-Version: share <microversion>`
  - `X-OpenStack-Manila-API-Version: <microversion>`
  - `X-Openstack-Request-Id: req-<uuid>`
- Supported microversion range is controlled by:
  - `MANILA_MICROVERSION_MIN`
  - `MANILA_MICROVERSION_MAX`
  - `MANILA_MICROVERSION_DEFAULT`
- Request bodies accept OpenStack-style envelopes:
  - `POST /v1/shares` accepts `{ "share": { ... } }`
  - `POST /v1/snapshots` accepts `{ "snapshot": { ... } }`
- Collection responses include links arrays:
  - `share_types_links`, `shares_links`, `snapshots_links`

## Keystone Token Validation and Policy

- All API routes except `/health` require `X-Auth-Token`.
- Validation mode:
  - If `KEYSTONE_URL` and `KEYSTONE_ADMIN_TOKEN` are set, tokens are validated against Keystone (`/v3/auth/tokens`).
  - Otherwise, static validation is used via `KEYSTONE_TOKEN_MAP`.
- `KEYSTONE_TOKEN_MAP` format:
  - `token=project_id:user_id:role1|role2;token2=project2:user2:member`
- Project-scoped policy checks:
  - Non-admin tokens can only access their own `project_id`.
  - Admin role can access all projects.

### Example share creation

```bash
curl -X POST http://localhost:8080/v1/shares \
  -H "X-Auth-Token: dev-admin" \
  -H "OpenStack-API-Version: share 2.93" \
  -H "Content-Type: application/json" \
  -d '{
    "share": {
      "project_id": "project-a",
      "name": "team-files",
      "description": "shared engineering space",
      "size": 50,
      "share_proto": "NFS",
      "share_type": "gold",
      "availability_zone": "zone-a"
    }
  }'
```

### Example snapshot creation

```bash
curl -X POST http://localhost:8080/v1/snapshots \
  -H "X-Auth-Token: dev-admin" \
  -H "Content-Type: application/json" \
  -d '{
    "snapshot": {
      "project_id": "project-a",
      "share_id": "<share-id>",
      "name": "team-files-snap-001",
      "description": "before release"
    }
  }'
```

## Build and Run

```bash
cd manila
dub build
./uim-manila-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | HTTP bind address |
| STORAGE_BACKEND | memory | `memory` or `postgres` |
| POSTGRES_DSN | postgresql://postgres:postgres@localhost:5432/manila | PostgreSQL DSN used when backend is `postgres` |
| MANILA_MICROVERSION_MIN | 2.1 | Lowest accepted microversion |
| MANILA_MICROVERSION_MAX | 2.93 | Highest accepted microversion |
| MANILA_MICROVERSION_DEFAULT | 2.93 | Response default microversion |
| KEYSTONE_URL | (empty) | Keystone base URL for live token validation |
| KEYSTONE_ADMIN_TOKEN | (empty) | Admin token used to call Keystone token validation API |
| KEYSTONE_TOKEN_MAP | (empty) | Static token map fallback (`token=project:user:roles`) |
| ALLOW_INSECURE_TOKENS | false | If true, unknown tokens are treated as project ids |

## Containers

Docker:

```bash
docker build -t uim-manila-service .
docker run -p 8080:8080 uim-manila-service
```

Podman:

```bash
podman build -t uim-manila-service .
podman run -p 8080:8080 uim-manila-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```