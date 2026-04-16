# uim-file-storage-service

A file-storage microservice built with **D** and **[vibe.d](https://vibed.org/)** following a combined **Clean** and **Hexagonal** (Ports & Adapters) architecture.

## Architecture

```
file-storage/
└── source/
    ├── app.d                          # Entry point – wires all layers together
    └── uim/infrastructure/file_storage/
        ├── domain/                    # Core business rules (no framework deps)
        │   ├── entities/stored_file.d # StoredFile value object
        │   └── ports/repositories/    # IFileRepository interface (port)
        ├── application/               # Use-case orchestration
        │   ├── dto/file_command.d     # UploadFileCommand, DownloadFileQuery, DeleteFileCommand
        │   └── usecases/              # UploadFile, DownloadFile, DeleteFile, ListFiles
        └── infrastructure/            # Adapters that fulfil the ports
            ├── http/controllers/      # FileStorageController (vibe.d HTTP adapter)
            └── persistence/memory/    # InMemoryFileRepository (in-memory adapter)
```

### Layers

| Layer | Responsibility |
|---|---|
| **Domain** | `StoredFile` entity; `IFileRepository` port |
| **Application** | Use-cases that implement business logic using only domain types |
| **Infrastructure** | HTTP controller (vibe.d) and in-memory repository adapter |

## HTTP API

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check – returns `{ "status": "ok" }` |
| `GET` | `/v1/files` | List all stored files (metadata only) |
| `POST` | `/v1/files?name=<filename>` | Upload a file; body = raw bytes; `Content-Type` header = MIME type |
| `GET` | `/v1/files/<id>` | Download a file by ID |
| `DELETE` | `/v1/files/<id>` | Delete a file by ID |

### Example

```bash
# Upload
curl -X POST "http://localhost:8080/v1/files?name=hello.txt" \
  -H "Content-Type: text/plain" \
  --data-binary "Hello, world!"

# List
curl http://localhost:8080/v1/files

# Download (replace <id> with the id returned by upload)
curl -OJ "http://localhost:8080/v1/files/<id>"

# Delete
curl -X DELETE "http://localhost:8080/v1/files/<id>"
```

## Building

```bash
cd file-storage
dub build
./uim-file-storage-service
```

## Configuration

| Environment variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | TCP port to listen on |
| `BIND_ADDRESS` | `0.0.0.0` | IP address to bind |

## Container

```bash
docker build -t uim-file-storage-service .
docker run -p 8080:8080 uim-file-storage-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
