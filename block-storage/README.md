# uim-block-storage-service

A block-storage microservice built with **D** and **[vibe.d](https://vibed.org/)** following a combined **Clean** and **Hexagonal** (Ports & Adapters) architecture.

## Architecture

```
block-storage/
├── dub.sdl
├── Dockerfile / Containerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── uml.md      ← UML class & sequence diagrams
├── nafv4.md    ← NAF v4 architecture views
└── source/
    ├── app.d                              # Entry point – wires all layers together
    └── uim/infrastructure/block_storage/
        ├── domain/                        # Core business rules (no framework deps)
        │   ├── entities/block_volume.d    # BlockVolume struct + VolumeState enum
        │   └── ports/repositories/        # IBlockVolumeRepository interface (port)
        ├── application/                   # Use-case orchestration
        │   ├── dto/volume_command.d       # Command/Query DTOs
        │   └── usecases/                  # CreateVolume, DeleteVolume, AttachVolume,
        │                                  # DetachVolume, ListVolumes, GetVolume
        └── infrastructure/               # Adapters that fulfil the ports
            ├── http/controllers/          # BlockStorageController (vibe.d HTTP adapter)
            └── persistence/memory/        # InMemoryBlockVolumeRepository
```

### Layers

| Layer | Responsibility |
|---|---|
| **Domain** | `BlockVolume` entity + `VolumeState` enum; `IBlockVolumeRepository` port |
| **Application** | Use-cases implementing block-volume lifecycle logic using only domain types |
| **Infrastructure** | HTTP controller (vibe.d) and in-memory repository adapter |

## HTTP API

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check – returns `{ "status": "ok" }` |
| `GET` | `/v1/volumes` | List all block volumes |
| `POST` | `/v1/volumes` | Create a new volume; body: `{ "name": "...", "sizeGiB": N }` |
| `GET` | `/v1/volumes/<id>` | Get volume details by ID |
| `DELETE` | `/v1/volumes/<id>` | Delete a volume (must be detached) |
| `POST` | `/v1/volumes/<id>/attach` | Attach volume to an instance; body: `{ "instanceId": "..." }` |
| `POST` | `/v1/volumes/<id>/detach` | Detach volume from its current instance |

### Volume states

```
available ──attach──▶ attached ──detach──▶ available
available ──delete──▶ (removed)
```

### Example

```bash
# Create a 100 GiB volume
curl -X POST http://localhost:8080/v1/volumes \
  -H "Content-Type: application/json" \
  -d '{"name":"data-vol","sizeGiB":100}'

# List volumes
curl http://localhost:8080/v1/volumes

# Get a specific volume (replace <id>)
curl http://localhost:8080/v1/volumes/<id>

# Attach to an instance
curl -X POST http://localhost:8080/v1/volumes/<id>/attach \
  -H "Content-Type: application/json" \
  -d '{"instanceId":"instance-abc"}'

# Detach
curl -X POST http://localhost:8080/v1/volumes/<id>/detach

# Delete
curl -X DELETE http://localhost:8080/v1/volumes/<id>
```

## Building

```bash
cd block-storage
dub build
./uim-block-storage-service
```

## Configuration

| Environment variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | TCP port to listen on |
| `BIND_ADDRESS` | `0.0.0.0` | IP address to bind |
| `PID_FILE` | `/var/run/uim-block-storage-service.pid` | Path for the PID file (pidman / process supervision) |

### PID file (pidman / process supervision)

On startup the service writes its PID to `PID_FILE`. This supports:

* **pidman** – a process-supervision tool that monitors services by their PID file and restarts them on failure.
* **init systems** – `systemd`, `runit`, or any supervisor that tracks a PID file.
* **container supervisors** – useful when the container runs multiple processes under `tini` or `s6`.

If the directory is not writable (e.g., in a read-only container), the write is silently skipped and the service continues normally.

## Container (Docker / Podman)

```bash
# Build
docker build -t uim-block-storage-service .

# Run
docker run -p 8080:8080 uim-block-storage-service

# Override the PID file path
docker run -p 8080:8080 -e PID_FILE=/tmp/bs.pid uim-block-storage-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

The deployment exposes `/health` as both readiness and liveness probes.
