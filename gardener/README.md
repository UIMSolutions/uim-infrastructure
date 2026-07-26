# UIM Gardener Service

Gardener-inspired cloud control plane service built with [vibe.d](https://vibed.org/) and [D](https://dlang.org/) using a clean and hexagonal architecture.

The service models a small control plane for managing:

- Gardens as tenant-level logical workspaces
- Seeds as backing Kubernetes clusters
- Shoots as managed clusters provisioned onto seeds

The code is intentionally small and in-memory first so it can act as a practical starting point for a larger controller-style service.

## Architecture

Domain Layer

Application Layer

Infrastructure Layer

- Inbound HTTP controller built with vibe.d
- Outbound in-memory repositories protected by a mutex
- Composition root in `source/app.d`

## API

### Health and Discovery

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/` | Service metadata |
| GET | `/api/v1` | Discovery payload |

### Gardens

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/gardens` | Create a garden |
| GET | `/api/v1/gardens` | List gardens |
| GET | `/api/v1/gardens/{name}` | Get a garden |
| DELETE | `/api/v1/gardens/{name}` | Delete a garden |

### Seeds

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/seeds` | Register a seed cluster |
| GET | `/api/v1/seeds` | List seeds |
| GET | `/api/v1/seeds/{name}` | Get a seed |
| DELETE | `/api/v1/seeds/{name}` | Delete a seed |

### Shoots

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/shoots` | Create a shoot |
| GET | `/api/v1/shoots` | List shoots |
| GET | `/api/v1/shoots/{name}` | Get a shoot |
| PATCH | `/api/v1/shoots/{name}/status` | Update shoot state |
| DELETE | `/api/v1/shoots/{name}` | Delete a shoot |

## Example

```bash
curl -X POST http://localhost:8080/api/v1/gardens \
  -H "Content-Type: application/json" \
  -d '{"name":"platform","purpose":"shared-services","owner":"platform-team","region":"eu-west-1"}'
```

```bash
curl -X POST http://localhost:8080/api/v1/seeds \
  -H "Content-Type: application/json" \
  -d '{"name":"seed-a","provider":"aws","region":"eu-west-1","kubeconfigRef":"/etc/gardener/seed-a.kubeconfig"}'
```

```bash
curl -X POST http://localhost:8080/api/v1/shoots \
  -H "Content-Type: application/json" \
  -d '{"name":"shoot-a","gardenName":"platform","seedName":"seed-a","region":"eu-west-1","kubernetesVersion":"1.30.0","purpose":"application"}'
```

## Run

### Local

```bash
cd gardener
dub build
./uim-gardener-service
```

### Docker

```bash
docker build -t uim-gardener-service .
docker run -p 8080:8080 uim-gardener-service
```

### Podman

```bash
podman build -t uim-gardener-service -f Containerfile .
podman run -p 8080:8080 uim-gardener-service
```

### Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
