# UIM DNS Service

A DNS-oriented service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture.

## Architecture

- Domain: DNS entities and ports (interfaces).
- Application: Use cases that enforce business rules.
- Infrastructure: HTTP adapter (vibe.d routes) and in-memory repository adapter.

### Layer mapping

- Domain: `source/dns_service/domain`
- Application: `source/dns_service/application`
- Infrastructure: `source/dns_service/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repository is an outbound adapter.

## API

- Health: `GET /health`
- List records: `GET /v1/records`
- Create record:
  - `POST /v1/records/<zone>/<name>/<type>/<value>/<ttl>`
  - Example: `/v1/records/example.local/api/A/10.0.0.5/120`
- Resolve record:
  - `GET /v1/resolve/<zone>/<name>/<type>`
  - Example: `/v1/resolve/example.local/api/A`

## Run locally

```bash
cd dns
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd dns
docker build -t uim-dns-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-dns-service uim-dns-service:latest
```

## Podman

Build:

```bash
cd dns
podman build -f Containerfile -t uim-dns-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-dns-service uim-dns-service:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Access from cluster tooling:

```bash
kubectl -n uim-dns port-forward service/uim-dns-service 8080:80
```

## Test

```bash
cd dns
dub test
```
