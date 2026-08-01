# uim-smtp-relay-service

SMTP relay microservice built with D and vibe.d using Clean + Hexagonal architecture.

## Highlights

- Domain/application/infrastructure separation (ports and adapters)
- SMTP relay adapter with plain, STARTTLS, TLS, and SMTP auth support
- JSON HTTP API for programmatic relay operations
- MVC HTML pages for compose and history views
- Ready for Docker, Podman, Cloud Foundry, and Kubernetes

## Project Structure

```text
smtp-relay/
├── dub.sdl
├── Dockerfile / Containerfile
├── manifest.yml
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── pvc.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Readme.md
├── Nafv4.md
├── UML.md
└── source/
    ├── app.d
    └── uim/infrastructure/smtp_relay/
        ├── domain/
        │   ├── entities/email_message.d
        │   └── ports/
        │       ├── repositories/email_message_repository.d
        │       └── services/smtp_relay_port.d
        ├── application/
        │   ├── dto/relay_message_command.d
        │   └── usecases/
        │       ├── relay_message.d
        │       ├── list_messages.d
        │       └── get_message.d
        └── infrastructure/
            ├── http/
            │   ├── controllers/api_controller.d
            │   ├── controllers/web_controller.d
            │   └── views/html_renderer.d
            ├── persistence/memory/email_message_repository.d
            └── smtp/smtp_relay_adapter.d
```

## Runtime Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP port |
| BIND_ADDRESS | 0.0.0.0 | Bind address |
| PID_FILE | /var/run/uim-smtp-relay-service.pid | PID file path |
| SMTP_HOST | mailhog | Target SMTP host |
| SMTP_PORT | 1025 | Target SMTP port |
| SMTP_FROM | noreply@uim.local | Default sender when none supplied |
| SMTP_SECURITY | plain | SMTP transport: plain, starttls, tls |
| SMTP_AUTH | none | SMTP auth mode: none, plain, login, xoauth2 |
| SMTP_USERNAME | (empty) | SMTP auth username |
| SMTP_PASSWORD | (empty) | SMTP auth password or OAuth token |
| STORE_BACKEND | file | Repository adapter: file or memory |
| MESSAGE_STORE_PATH | /tmp/uim-smtp-relay-messages.json | JSON file used by file repository |

## HTTP API

| Method | Path | Purpose |
|---|---|---|
| GET | /health | Health probe |
| GET | /api/v1/messages | List relayed messages |
| GET | /api/v1/messages/{id} | Get message details |
| POST | /api/v1/messages | Relay a message |

### Relay Request Example

```json
{
  "sender": "alerts@uim.local",
  "recipients": ["alice@example.com", "bob@example.com"],
  "subject": "Deployment complete",
  "body": "The deployment completed successfully."
}
```

## MVC Web Pages

- GET /: landing page
- GET /compose: compose form
- POST /compose: submit relay request
- GET /messages: relay history table
- GET /messages/{id}: message detail page

## Local Build and Run

```bash
cd smtp-relay
dub build
./uim-smtp-relay-service
```

## Docker

```bash
docker build -t uim-smtp-relay-service .
docker run --rm -p 8080:8080 \
  -e SMTP_HOST=host.docker.internal \
  -e SMTP_PORT=1025 \
  uim-smtp-relay-service
```

## Docker Compose (with MailHog)

```bash
docker compose up --build
```

Endpoints:

- Service UI/API: http://localhost:8080
- MailHog UI: http://localhost:8025

## Podman

```bash
podman build -t uim-smtp-relay-service .
podman run --rm -p 8080:8080 \
  -e SMTP_HOST=host.containers.internal \
  -e SMTP_PORT=1025 \
  uim-smtp-relay-service
```

## Podman Play (with MailHog)

```bash
podman build -t localhost/uim-smtp-relay-service:dev .
podman play kube podman-play.yaml
```

To stop:

```bash
podman play kube --down podman-play.yaml
```

## Cloud Foundry

Build binary first, then push with the binary buildpack:

```bash
dub build --build=release
cf push -f manifest.yml
```

Cloud Foundry injects PORT at runtime; the service reads it automatically.

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Notes

- SMTP adapter now uses vibe.d SMTP client with optional STARTTLS/TLS and AUTH (PLAIN, LOGIN, XOAUTH2).
- File-based persistence is enabled by default via MESSAGE_STORE_PATH; set STORE_BACKEND=memory to revert to in-memory behavior.
- Kubernetes persistence is configured via k8s/pvc.yaml and mounted at /data.
