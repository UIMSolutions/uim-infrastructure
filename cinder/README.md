# uim-cinder-service

A Cinder-inspired block storage microservice built with D and vibe.d, structured around a combination of Clean Architecture and Hexagonal Architecture.

The service follows OpenStack Block Storage (Cinder) concepts and route shapes for volumes, snapshots, types, and actions.

References:
- https://docs.openstack.org/cinder/latest/
- https://opendev.org/openstack/cinder

## Architecture

```
cinder/
└── source/
    ├── app.d
    └── uim/infrastructure/cinder/
        ├── domain/
        │   ├── entities/
        │   └── ports/repositories/
        ├── application/
        │   ├── dto/cinder_command.d
        │   └── usecases/
        └── infrastructure/
            ├── http/controllers/cinder.d
            └── persistence/memory/
```

## HTTP API (OpenStack-style subset)

| Method | Path | Description |
|---|---|---|
| GET | /health | Liveness/readiness probe |
| GET | /v3 | Cinder version discovery payload |
| GET | /v3/volumes | List volumes |
| GET | /v3/volumes/detail | Detailed list volumes |
| POST | /v3/volumes | Create volume |
| GET | /v3/volumes/{id} | Show volume |
| DELETE | /v3/volumes/{id} | Delete volume |
| POST | /v3/volumes/{id}/action | Volume actions (`os-attach`, `os-detach`) |
| GET | /v3/snapshots | List snapshots |
| POST | /v3/snapshots | Create snapshot |
| GET | /v3/snapshots/{id} | Show snapshot |
| DELETE | /v3/snapshots/{id} | Delete snapshot |
| GET | /v3/types | List volume types |
| GET | /v3/limits | Basic limits payload |

## Build and Run

```bash
cd cinder
dub build
./uim-cinder-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | HTTP bind address |
| CINDER_MICROVERSION_MIN | 3.0 | Lowest microversion in response headers |
| CINDER_MICROVERSION_MAX | 3.70 | Highest microversion in response headers |
| CINDER_MICROVERSION_DEFAULT | 3.70 | Default microversion in response headers |

## Containers

Docker:

```bash
docker build -t uim-cinder-service .
docker run -p 8080:8080 uim-cinder-service
```

Podman:

```bash
podman build -t uim-cinder-service .
podman run -p 8080:8080 uim-cinder-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
