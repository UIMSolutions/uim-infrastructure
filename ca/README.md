# uim-ca-service

In-cluster Certificate Authority (CA) service built with D and vibe.d using a combined Clean + Hexagonal architecture.

## Features

- Initializes a cluster root CA at runtime
- Issues leaf certificates for workloads
- Supports SAN entries for service DNS names
- Lists, reads, and revokes issued certificates
- OpenSSL-backed certificate generation and signing
- Docker + Podman + Kubernetes ready

## API

### Health

```http
GET /health
```

### Initialize Root CA

```http
POST /v1/ca/init
Content-Type: application/json

{
  "name": "cluster-root-ca",
  "common_name": "uim.cluster.local",
  "valid_days": 3650
}
```

### Get Current CA

```http
GET /v1/ca
```

### Issue Certificate

```http
POST /v1/certificates
Content-Type: application/json

{
  "common_name": "web.default.svc.cluster.local",
  "subject_alt_names": [
    "web.default.svc.cluster.local",
    "web.default.svc"
  ],
  "valid_days": 365,
  "namespace": "default"
}
```

### List Certificates

```http
GET /v1/certificates
GET /v1/certificates?namespace=default
```

### Get Certificate

```http
GET /v1/certificates/{id}
```

### Revoke Certificate

```http
POST /v1/certificates/{id}/revoke
Content-Type: application/json

{
  "reason": "workload-decommissioned"
}
```

## Architecture

```text
source/
└── uim/infrastructure/ca/
    ├── domain/
    │   ├── entities/                 # CA and certificate entities
    │   └── ports/
    │       ├── repositories/         # Repository interfaces
    │       └── crypto/               # Crypto engine interface
    ├── application/
    │   ├── dto/                      # Commands
    │   └── usecases/                 # Use-case orchestration
    └── infrastructure/
        ├── http/controllers/         # vibe.d HTTP adapter
        ├── persistence/memory/       # In-memory adapters
        └── crypto/                   # OpenSSL adapter
```

## Local Run

```bash
cd ca
dub build
./uim-ca-service
```

Defaults:

- `PORT=9321`
- `BIND_ADDRESS=0.0.0.0`

## Docker / Podman

```bash
cd ca

docker build -t uim-ca-service .
docker run -p 9321:9321 uim-ca-service

podman build -t uim-ca-service .
podman run -p 9321:9321 uim-ca-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Notes

- This service keeps CA state and certificates in-memory for now.
- For production, replace in-memory persistence with durable storage and lock down key material handling.
