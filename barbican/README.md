# uim-barbican-service

A secrets management service inspired by [OpenStack Barbican](https://github.com/openstack/barbican), built with **D** and **vibe.d** using clean + hexagonal architecture.

## What it does

Provides a REST API for secure storage and management of secret keying material:

| Resource | Description |
|---|---|
| **Secrets** | Symmetric keys, asymmetric keys, certificates, raw payloads, passphrases |
| **Containers** | Named groups of secrets (generic, RSA key-pair, certificate chain) |
| **Orders** | Asynchronous requests to generate a new secret key |

## API Reference

### Health

```
GET /health
```

### Secrets

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/secrets` | List secrets (`?project_id=`) |
| `POST` | `/v1/secrets` | Create / store a secret |
| `GET` | `/v1/secrets/{id}` | Get secret metadata |
| `PUT` | `/v1/secrets/{id}` | Add payload to a two-step secret |
| `GET` | `/v1/secrets/{id}/payload` | Retrieve the raw secret payload |
| `DELETE` | `/v1/secrets/{id}` | Delete a secret |

#### Create secret (one-step)

```json
POST /v1/secrets
{
  "name": "my-aes-key",
  "secret_type": "symmetric",
  "algorithm": "aes",
  "bit_length": 256,
  "mode": "cbc",
  "payload": "base64encodedkey==",
  "payload_content_type": "application/octet-stream"
}
```

#### Two-step secret (metadata first, payload later)

```json
POST /v1/secrets
{ "name": "deferred-key", "secret_type": "symmetric", "algorithm": "aes", "bit_length": 256 }

PUT /v1/secrets/{id}
{ "payload": "base64encodedkey==", "payload_content_type": "application/octet-stream" }
```

### Containers

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/containers` | List containers |
| `POST` | `/v1/containers` | Create a container |
| `GET` | `/v1/containers/{id}` | Get container |
| `DELETE` | `/v1/containers/{id}` | Delete container |

```json
POST /v1/containers
{
  "name": "rsa-keypair",
  "type": "rsa",
  "secret_refs": [
    { "name": "private_key", "secret_id": "<id>" },
    { "name": "public_key",  "secret_id": "<id>" }
  ]
}
```

### Orders (key generation)

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/orders` | List orders |
| `POST` | `/v1/orders` | Create an order (generates a secret) |
| `GET` | `/v1/orders/{id}` | Get order status |
| `DELETE` | `/v1/orders/{id}` | Delete an order |

```json
POST /v1/orders
{
  "type": "key",
  "meta": {
    "algorithm": "aes",
    "bit_length": 256,
    "mode": "cbc",
    "name": "generated-key"
  }
}
```

## Secret types

| Type | Description |
|---|---|
| `symmetric` | AES / HMAC keys |
| `asymmetric` | RSA / EC key pairs |
| `certificate` | X.509 certificates |
| `opaque` | Raw binary blobs |
| `passphrase` | Human-readable passwords |

## Architecture

```
source/
└── uim/infrastructure/barbican/
    ├── domain/
    │   ├── entities/        # Secret, SecretContainer, Order (pure D structs)
    │   └── ports/
    │       └── repositories/ # ISecretRepository, ISecretContainerRepository, IOrderRepository
    ├── application/
    │   ├── dto/             # Commands (CreateSecretCommand, …)
    │   └── usecases/        # One class per use case
    └── infrastructure/
        ├── http/
        │   └── controllers/ # BarbicanController — vibe.d HTTP adapter
        └── persistence/
            └── memory/      # In-memory thread-safe repositories
```

## Running locally

```bash
# Build
dub build

# Run (default port 9311)
./uim-barbican-service

# Custom port
PORT=8080 ./uim-barbican-service
```

## Docker / Podman

```bash
# Build image
docker build -t uim-barbican-service .
# or
podman build -t uim-barbican-service .

# Run
docker run -p 9311:9311 uim-barbican-service
podman run -p 9311:9311 uim-barbican-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
