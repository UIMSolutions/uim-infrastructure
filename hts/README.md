# uim-hts-service

A high-throughput sequencing (HTS) oriented service implemented with D and vibe.d using Clean and Hexagonal architecture.

Features:

- Ingest and query HTS-like text formats inspired by htslib workflows: SAM, VCF, and FASTQ.
- JSON API endpoints for automation and MVC HTML pages for manual operations.
- UNIX authentication management support:
  - read and manipulate passwd/shadow data,
  - create and compare password hashes,
  - generate UNIX crypt-compatible salts.
- Runtime compatibility with Docker, Podman, Cloud Foundry, and Kubernetes.

## Architecture layout

```text
hts/
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
    └── uim/infrastructure/hts_service/
        ├── domain/
        │   ├── entities/
        │   │   ├── hts_record.d
        │   │   └── unix_user.d
        │   └── ports/
        │       ├── parsers/hts_parser.d
        │       ├── repositories/sequencing_repository.d
        │       ├── repositories/unix_auth_repository.d
        │       └── security/password_crypto.d
        ├── application/
        │   ├── dto/
        │   │   ├── hts_commands.d
        │   │   └── unix_auth_commands.d
        │   └── usecases/
        │       ├── ingest_dataset.d
        │       ├── list_dataset_records.d
        │       ├── list_by_reference.d
        │       ├── list_datasets.d
        │       ├── list_unix_users.d
        │       ├── get_unix_user.d
        │       ├── create_unix_user.d
        │       ├── set_unix_password.d
        │       ├── generate_unix_hash.d
        │       └── verify_unix_password.d
        └── infrastructure/
            ├── parsers/hts_parser.d
            ├── persistence/memory/sequencing_repository.d
            ├── persistence/files/unix_auth_repository.d
            ├── security/crypt_password_crypto.d
            └── http/
                ├── controllers/api_controller.d
                ├── controllers/web_controller.d
                └── views/html_renderer.d
```

## JSON API

| Method | Path | Description |
| --- | --- | --- |
| GET | /health | Health check |
| GET | /v1/hts/datasets | List dataset ids |
| POST | /v1/hts/datasets | Ingest dataset content |
| GET | /v1/hts/datasets/{datasetId} | List dataset records |
| GET | /v1/hts/query/reference?datasetId=...&reference=... | Filter records by reference |
| GET | /v1/unix/users | List UNIX users |
| GET | /v1/unix/users/{username} | User detail |
| POST | /v1/unix/users | Create user |
| POST | /v1/unix/users/{username}/password | Set password hash |
| POST | /v1/unix/hash | Generate crypt salt/hash |
| POST | /v1/unix/verify | Verify password against hash |

### Ingest example

```json
{
  "datasetId": "run-2026-08-01",
  "format": "sam",
  "rawContent": "@HD\tVN:1.6\nread001\t0\tchr1\t100\t60\t50M\t*\t0\t0\tACGT\tFFFF"
}
```

### UNIX hash example

```json
{
  "password": "secret123",
  "algorithm": "sha512"
}
```

## MVC HTML routes

| Method | Path | Description |
| --- | --- | --- |
| GET | / | Dataset landing page |
| GET | /datasets/new | Ingest form |
| POST | /datasets/new | Submit ingest form |
| GET | /datasets/{datasetId}?reference=chr1 | Dataset detail/filter |
| GET | /users | UNIX users list |
| GET | /users/new | Create UNIX user form |
| POST | /users/new | Submit user creation |
| GET | /users/{username} | User detail |
| POST | /users/{username}/password | Update password hash |
| GET | /hash | Hash generation page |
| POST | /hash | Generate hash |

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | Bind address |
| PASSWD_FILE | /etc/passwd | Path to passwd source |
| SHADOW_FILE | /etc/shadow | Path to shadow source |

## Local run

```bash
cd hts
dub run
```

Safer local testing with sandbox files:

```bash
cp /etc/passwd ./passwd.sample
cp /etc/shadow ./shadow.sample
PASSWD_FILE=./passwd.sample SHADOW_FILE=./shadow.sample dub run
```

## Smoke test

The folder [hts/scripts/seed](hts/scripts/seed) contains tiny SAM, VCF, and FASTQ examples.

Run the one-command API smoke test against a running service:

```bash
./scripts/smoke-test.sh
```

If the service is on a different host/port:

```bash
BASE_URL=http://127.0.0.1:8080 ./scripts/smoke-test.sh
```

## Docker

```bash
docker build -t uim-hts-service .
docker run --rm -p 8080:8080 -e PASSWD_FILE=/data/passwd -e SHADOW_FILE=/data/shadow uim-hts-service
```

## Podman

```bash
podman build -t uim-hts-service .
podman run --rm -p 8080:8080 -e PASSWD_FILE=/data/passwd -e SHADOW_FILE=/data/shadow uim-hts-service
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

## Notes

- This service provides parser primitives for SAM/VCF/FASTQ text and is intentionally lightweight.
- Binary BAM/CRAM and BGZF indexing are not implemented in this initial version.
