# UIM MongoDB Service

A MongoDB document service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture.

## Architecture

- **Domain**: Document entity and repository port (interface).
- **Application**: Use cases that enforce business rules (insert, find, list, update, delete).
- **Infrastructure**: HTTP adapter (vibe.d routes) and two repository adapters — in-memory (testing) and MongoDB (production via vibe.d MongoClient).

### Layer mapping

| Layer          | Path                                           |
|---------------|-------------------------------------------------|
| Domain        | `source/uim/infrastructure/mongo/domain`        |
| Application   | `source/uim/infrastructure/mongo/application`   |
| Infrastructure| `source/uim/infrastructure/mongo/infrastructure`|
| Composition   | `source/app.d`                                  |

The HTTP layer is the inbound adapter and the repository is the outbound adapter. When `MONGO_URI` is set, the service connects to a real MongoDB instance; otherwise it uses an in-memory store.

## API

| Method   | Endpoint                                     | Description             |
|----------|----------------------------------------------|-------------------------|
| `GET`    | `/health`                                    | Health check            |
| `GET`    | `/v1/documents/<db>/<collection>`            | List all documents      |
| `GET`    | `/v1/documents/<db>/<collection>/<id>`       | Find document by id     |
| `POST`   | `/v1/documents/<db>/<collection>`            | Insert document (JSON body) |
| `PUT`    | `/v1/documents/<db>/<collection>/<id>`       | Update document (JSON body) |
| `DELETE` | `/v1/documents/<db>/<collection>/<id>`       | Delete document         |

### Examples

```bash
# Insert
curl -X POST http://localhost:8080/v1/documents/mydb/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "age": 30}'

# List
curl http://localhost:8080/v1/documents/mydb/users

# Find by id
curl http://localhost:8080/v1/documents/mydb/users/<id>

# Update
curl -X PUT http://localhost:8080/v1/documents/mydb/users/<id> \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "age": 31}'

# Delete
curl -X DELETE http://localhost:8080/v1/documents/mydb/users/<id>
```

## Run locally

```bash
cd mongo
dub run
```

With a real MongoDB instance:

```bash
MONGO_URI=mongodb://localhost:27017 dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)
- `MONGO_URI` (optional — omit for in-memory mode)

## Docker

Build:

```bash
cd mongo
docker build -t uim-mongo-service:latest .
```

Run with a MongoDB container:

```bash
docker network create uim-net
docker run -d --name mongo --network uim-net mongo:7
docker run --rm -p 8080:8080 --network uim-net \
  -e MONGO_URI=mongodb://mongo:27017 \
  --name uim-mongo-service uim-mongo-service:latest
```

## Podman

Build:

```bash
cd mongo
podman build -f Containerfile -t uim-mongo-service:latest .
```

Run with a MongoDB container:

```bash
podman network create uim-net
podman run -d --name mongo --network uim-net mongo:7
podman run --rm -p 8080:8080 --network uim-net \
  -e MONGO_URI=mongodb://mongo:27017 \
  --name uim-mongo-service uim-mongo-service:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/mongo-statefulset.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Access from cluster:

```bash
kubectl -n uim-mongo port-forward service/uim-mongo-service 8080:80
```

## Test

```bash
cd mongo
dub test
```
