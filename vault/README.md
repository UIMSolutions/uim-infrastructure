# uim-vault-service

A Vault-inspired secrets lifecycle microservice built with D and vibe.d, structured around a combination of Clean Architecture and Hexagonal Architecture.

The service follows HashiCorp Vault product positioning as identity-based security for managing access to secrets and protecting sensitive data across humans, machines, services, and AI agents.

Reference description:
https://www.hashicorp.com/en/products/vault

## Architecture

```
vault/
└── source/
    ├── app.d
    └── uim/infrastructure/vault/
        ├── domain/
        │   ├── entities/secret_record.d
        │   └── ports/secret_repository.d
        ├── application/
        │   ├── dto/vault_command.d
        │   └── usecases/
        │       ├── list_secrets.d
        │       ├── get_secret.d
        │       ├── create_secret.d
        │       ├── issue_certificate.d
        │       └── revoke_certificate.d
        └── infrastructure/
            ├── persistence/memory/secret_repository.d
            └── http/controllers/vault.d
```

## HTTP API

| Method | Path | Description |
|---|---|---|
| GET | /health | Liveness and metadata probe |
| GET | /v1/secrets | List secret metadata |
| POST | /v1/secrets | Create a secret (value is stored, always redacted in responses) |
| GET | /v1/secrets/{id} | Read secret metadata |
| POST | /v1/certificates | Issue a certificate record |
| POST | /v1/certificates/{serial}/revoke | Revoke a certificate record |

### Example: create secret

```bash
curl -X POST http://localhost:8080/v1/secrets \
  -H "Content-Type: application/json" \
  -d '{
    "path": "kv/team-a/db/password",
    "value": "super-secret",
    "owner_identity": "service-team-a",
    "category": "secret",
    "ttl_seconds": 3600
  }'
```

## Build and Run

```bash
cd vault
dub build
./uim-vault-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | HTTP bind address |
| VAULT_SERVER_NAME | uim-vault-service | Service name returned by `/health` |
| VAULT_SERVER_VERSION | 0.1.0 | Service version returned by `/health` |
| VAULT_DEFAULT_TTL_SECONDS | 3600 | Default TTL for secrets and certificates |

## Containers

Docker:

```bash
docker build -t uim-vault-service .
docker run -p 8080:8080 uim-vault-service
```

Podman:

```bash
podman build -t uim-vault-service .
podman run -p 8080:8080 uim-vault-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
