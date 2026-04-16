# uim-load-balancing-service

A load-balancing service built with **D** and **vibe.d**, following a clean **hexagonal (ports-and-adapters) architecture**.

## Architecture

```
load-balancing/
├── dub.sdl
├── Dockerfile / Containerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── source/
    ├── app.d                          ← entry point / wiring
    └── uim/infrastructure/load_balancing/
        ├── domain/                    ← pure business rules
        │   ├── entities/
        │   │   └── backend.d          ← Backend struct
        │   └── ports/
        │       ├── repositories/
        │       │   └── backend.d      ← IBackendRepository interface
        │       └── selectors/
        │           └── backend.d      ← IBackendSelector interface
        ├── application/               ← use cases / orchestration
        │   ├── dto/
        │   │   └── backend_command.d  ← RegisterBackendCommand, DeregisterBackendCommand
        │   └── usecases/
        │       ├── register_backend.d
        │       ├── deregister_backend.d
        │       ├── list_backends.d
        │       └── select_backend.d
        └── infrastructure/            ← adapters (HTTP, persistence, routing)
            ├── http/controllers/
            │   └── load_balancer.d    ← HTTP controller + reverse-proxy
            ├── persistence/memory/
            │   └── backend_repository.d  ← in-memory IBackendRepository
            └── routing/
                └── round_robin_selector.d ← round-robin IBackendSelector
```

### Hexagonal layers

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| **Domain** | `Backend` entity, repository port, selector port | none |
| **Application** | Use-case orchestration, DTOs | Domain only |
| **Infrastructure** | HTTP controller, in-memory persistence, routing algorithms | Application + vibe.d |

## HTTP API

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Liveness check |
| `GET` | `/v1/backends` | List registered backends |
| `POST` | `/v1/backends/<id>/<host>/<port>[/<weight>]` | Register a backend |
| `DELETE` | `/v1/backends/<id>` | Deregister a backend |
| `ANY` | `/*` | Proxy request to the next healthy backend (round-robin) |

### Examples

```bash
# Register two backends
curl -X POST http://localhost:8080/v1/backends/b1/10.0.0.1/9000
curl -X POST http://localhost:8080/v1/backends/b2/10.0.0.2/9000

# List backends
curl http://localhost:8080/v1/backends

# Proxy a GET request – forwarded to b1 then b2 alternately
curl http://localhost:8080/api/data

# Deregister a backend
curl -X DELETE http://localhost:8080/v1/backends/b1
```

## Building

```bash
cd load-balancing
dub build
./uim-load-balancing-service
```

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Listening port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |

## Docker

```bash
docker build -t uim-load-balancing-service .
docker run -p 8080:8080 uim-load-balancing-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
