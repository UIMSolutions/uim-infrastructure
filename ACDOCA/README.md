# uim-acdoca-service

A Universal Journal style microservice inspired by SAP ACDOCA, implemented with **D** and **vibe.d** using **Clean** and **Hexagonal** architecture.

Features:
- JSON HTTP controllers for integration use-cases.
- MVC HTML pages for manual journal posting and browsing.
- Runtime compatibility with Docker, Podman, Cloud Foundry, and Kubernetes.

## Architecture layout

```text
ACDOCA/
├── dub.sdl
├── Dockerfile
├── Containerfile
├── manifest.yml
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── README.md
├── Readme.md
├── Nafv4.md
├── UML.md
└── source/
    ├── app.d
    └── uim/infrastructure/acdoca_service/
        ├── domain/
        │   ├── entities/journal_entry.d
        │   └── ports/repositories/journal_entry_repository.d
        ├── application/
        │   ├── dto/journal_entry_command.d
        │   └── usecases/
        │       ├── create_journal_entry.d
        │       ├── list_journal_entries.d
        │       ├── get_journal_entry.d
        │       └── delete_journal_entry.d
        └── infrastructure/
            ├── persistence/memory/journal_entry_repository.d
            └── http/
                ├── controllers/
                │   ├── api_controller.d
                │   └── web_controller.d
                └── views/html_renderer.d
```

## HTTP JSON API

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/v1/journal-entries` | List journal entries |
| `POST` | `/v1/journal-entries` | Create journal entry |
| `GET` | `/v1/journal-entries/<id>` | Get journal entry by id |
| `DELETE` | `/v1/journal-entries/<id>` | Delete journal entry |

### Example create payload

```json
{
  "companyCode": "1000",
  "fiscalYear": 2026,
  "documentNumber": 900001,
  "lineItem": 1,
  "glAccount": "400000",
  "currency": "EUR",
  "amount": 1250.75,
  "indicator": "debit",
  "text": "Sales posting",
  "postingDate": "2026-01-15"
}
```

## MVC HTML routes

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | Journal list view |
| `GET` | `/entries` | Journal list view |
| `GET` | `/entries/new` | Journal post form |
| `POST` | `/entries/new` | Submit journal post form |
| `GET` | `/entries/<id>` | Journal detail view |

## Local run

```bash
cd ACDOCA
dub run
```

Environment variables:

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | HTTP listen port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `PID_FILE` | `/var/run/uim-acdoca-service.pid` | PID file path |
| `ACDOCA_DEFAULT_COMPANY_CODE` | `1000` | Default company code in MVC form |
| `STORAGE_BACKEND` | `memory` | `memory` or `postgres` |
| `POSTGRES_DSN` | `postgresql://postgres:postgres@localhost:5432/acdoca` | PostgreSQL DSN used when `STORAGE_BACKEND=postgres` |
| `AUTH_MODE` | `none` | `none`, `bearer`, `jwt`, or `oauth2` |
| `AUTH_TOKEN` | `` | Required when `AUTH_MODE=bearer` |
| `AUTH_JWT_TOKEN` | `` | Required when `AUTH_MODE=jwt`; exact JWT token to accept |
| `AUTH_REQUIRED_SCOPE` | `acdoca.write` | Required scope for `oauth2` mode |
| `OAUTH2_TOKEN_MAP` | `` | Token-to-scope map, e.g. `t1=acdoca.read|acdoca.write;t2=acdoca.read` |

Write operations protected by auth middleware:

- `POST /v1/journal-entries`
- `DELETE /v1/journal-entries/<id>`
- `POST /entries/new`

## Docker

```bash
docker build -t uim-acdoca-service .
docker run --rm -p 8080:8080 uim-acdoca-service
```

## Podman

```bash
podman build -t uim-acdoca-service .
podman run --rm -p 8080:8080 uim-acdoca-service
```

## Docker Compose (service + PostgreSQL)

```bash
docker compose up --build
```

Shortcut script:

```bash
./scripts/dev-up.sh
```

The compose stack in [ACDOCA/docker-compose.yml](ACDOCA/docker-compose.yml) starts:
- `acdoca` on port `8080`
- `postgres` on port `5432`

It configures `STORAGE_BACKEND=postgres` and a working `POSTGRES_DSN` automatically.

To stop and remove containers:

```bash
docker compose down
```

Shortcut script:

```bash
./scripts/dev-down.sh
```

To stop and remove containers including PostgreSQL volume data:

```bash
docker compose down -v
```

Shortcut script:

```bash
./scripts/dev-down.sh --purge
```

Quick smoke test:

```bash
curl -X POST http://localhost:8080/v1/journal-entries \
  -H "Content-Type: application/json" \
  -d '{
    "companyCode":"1000",
    "fiscalYear":2026,
    "documentNumber":900001,
    "lineItem":1,
    "glAccount":"400000",
    "currency":"EUR",
    "amount":1250.75,
    "indicator":"debit",
    "text":"Sales posting",
    "postingDate":"2026-01-15"
  }'

curl http://localhost:8080/v1/journal-entries
```

## Podman Compose (alternative)

If you use Podman:

```bash
podman compose up --build
```

## Cloud Foundry

```bash
cf push -f manifest.yml
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
