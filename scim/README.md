# uim-scim-service

SCIM 2.0 service implementation with D and vibe.d, organized with Clean Architecture and Hexagonal Architecture.

The service follows the SCIM model and endpoint families described at [scim.cloud](https://scim.cloud/) and RFC7643/RFC7644, focusing on practical user and group provisioning flows.

## Architecture

```text
scim/
└── source/
    ├── app.d
    └── uim/infrastructure/scim/
        ├── domain/
        │   ├── entities/
        │   │   ├── user.d
        │   │   └── group.d
        │   └── ports/repositories/
        ├── application/
        │   ├── dto/scim_commands.d
        │   └── usecases/
        └── infrastructure/
            ├── http/controllers/scim.d
            └── persistence/memory/
```

## API

### Discovery endpoints

- `GET /scim/v2/ServiceProviderConfig`
- `GET /scim/v2/ResourceTypes`
- `GET /scim/v2/Schemas`

### User endpoints

- `GET /scim/v2/Users`
- `POST /scim/v2/Users`
- `GET /scim/v2/Users/{id}`
- `PUT /scim/v2/Users/{id}`
- `PATCH /scim/v2/Users/{id}`
- `DELETE /scim/v2/Users/{id}`

### Group endpoints

- `GET /scim/v2/Groups`
- `POST /scim/v2/Groups`
- `GET /scim/v2/Groups/{id}`
- `PUT /scim/v2/Groups/{id}`
- `PATCH /scim/v2/Groups/{id}`
- `DELETE /scim/v2/Groups/{id}`

### Bulk endpoint

- `POST /scim/v2/Bulk`

### Health endpoint

- `GET /health`

## Filtering and paging

- `filter` supports basic `eq` expressions for key attributes:
  - Users: `userName`, `externalId`, `displayName`
  - Groups: `displayName`, `externalId`
- `startIndex` and `count` are supported on list endpoints.

## Authentication and authorization

- SCIM endpoints require `Authorization: Bearer <token>`.
- Discovery endpoints can be made public via `SCIM_ALLOW_ANONYMOUS_DISCOVERY=true`.
- Bulk endpoint requires `admin` role.
- Static token map format:
  - `SCIM_TOKEN_MAP=token=subject:role1|role2;token2=subject2:member`

Example:

```bash
curl -H "Authorization: Bearer dev-admin" http://localhost:8080/scim/v2/Users
```

## Storage backend

- `STORAGE_BACKEND=memory` (default) uses in-memory repositories.
- `STORAGE_BACKEND=postgres` uses PostgreSQL repositories through `psql`.
- Set `POSTGRES_DSN` when using postgres backend.

Example:

```bash
curl "http://localhost:8080/scim/v2/Users?filter=userName%20eq%20%22dschrute%22&startIndex=1&count=10"
```

## Build and run

```bash
cd scim
dub build
./uim-scim-service
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | HTTP port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `SCIM_BASE_URL` | `http://localhost:8080/scim/v2` | Base URL used in SCIM `meta.location` and `$ref` |
| `STORAGE_BACKEND` | `memory` | `memory` or `postgres` |
| `POSTGRES_DSN` | `postgresql://postgres:postgres@localhost:5432/scim` | PostgreSQL DSN for `postgres` backend |
| `SCIM_TOKEN_MAP` | (empty) | Static bearer token mapping |
| `ALLOW_INSECURE_TOKENS` | `false` | If true, unknown tokens become member tokens |
| `SCIM_ALLOW_ANONYMOUS_DISCOVERY` | `false` | If true, discovery endpoints are public |

## Docker

```bash
docker build -t uim-scim-service .
docker run -p 8080:8080 uim-scim-service
```

## Podman

```bash
podman build -t uim-scim-service .
podman run -p 8080:8080 uim-scim-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
