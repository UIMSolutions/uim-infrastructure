# uim-logging-service

A structured logging service built with **D** and **[vibe.d](https://vibed.org/)** following **clean / hexagonal architecture**.

## Architecture

```
source/
├── app.d                                        # Bootstrap – wires dependencies and starts HTTP server
└── uim/infrastructure/logging/
    ├── domain/                                  # Business logic – no framework dependencies
    │   ├── entities/log_entry.d                 # LogEntry struct + LogLevel enum
    │   └── ports/repositories/logs.d            # ILogsRepository interface (port)
    ├── application/                             # Use cases – orchestrate domain objects
    │   ├── dto/log_command.d                    # WriteLogCommand, QueryLogsQuery
    │   └── usecases/
    │       ├── write_log.d                      # WriteLogUseCase
    │       ├── query_logs.d                     # QueryLogsUseCase
    │       └── list_logs.d                      # ListLogsUseCase
    └── infrastructure/                          # Framework-specific adapters
        ├── http/controllers/logging.d           # LoggingController (vibe.d HTTP)
        └── persistence/memory/logs_repository.d # InMemoryLogsRepository (adapter)
```

Dependencies flow strictly **inward**: Infrastructure → Application → Domain.

## HTTP API

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/health` | Health check |
| `GET`  | `/v1/logs` | List all log entries |
| `GET`  | `/v1/logs/<service>` | Query entries by service |
| `GET`  | `/v1/logs/<service>/<level>` | Query entries by service and level |
| `POST` | `/v1/logs/<service>/<level>/<message>` | Write a new log entry |

### Log levels

`DEBUG` · `INFO` · `WARNING` · `ERROR` · `CRITICAL`

### Examples

```bash
# Write a log entry
curl -X POST http://localhost:8080/v1/logs/my-service/INFO/application+started

# List all entries
curl http://localhost:8080/v1/logs

# Query by service
curl http://localhost:8080/v1/logs/my-service

# Query by service and level
curl http://localhost:8080/v1/logs/my-service/ERROR
```

## Building

```bash
cd logging
dub build
```

## Running

```bash
PORT=8080 BIND_ADDRESS=0.0.0.0 ./uim-logging-service
```

## Docker

```bash
# Build
docker build -t uim-logging-service .

# Run
docker run -p 8080:8080 uim-logging-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment variable | Default | Description |
|----------------------|---------|-------------|
| `PORT` | `8080` | TCP port to listen on |
| `BIND_ADDRESS` | `0.0.0.0` | Interface to bind to |
