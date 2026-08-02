# NAF v4 - uim-hts-service

## A.1 Capability View

Capability delivered:

- Manage HTS-like sequencing content for SAM, VCF, and FASTQ payloads.
- Provide API and MVC interfaces for dataset ingestion and query.
- Provide UNIX auth operations for passwd/shadow manipulation and crypt hashing workflows.

## A.2 Logical View

Primary logical components:

- HTS API Controller
- HTS Web Controller
- Dataset Ingest and Query Use Cases
- Sequencing Repository Port + InMemory Adapter
- HTS Parser Port + Basic Parser Adapter
- UNIX Auth Repository Port + File Adapter
- Password Crypto Port + POSIX crypt Adapter

## A.3 Service View

Exposed services:

- JSON endpoints under /v1/hts/\* and /v1/unix/\*.
- HTML endpoints under /datasets/*, /users/*, /hash, and /.

## A.4 Deployment View

Deployment targets:

- Native executable process
- Docker/Podman OCI container
- Cloud Foundry app via binary buildpack
- Kubernetes deployment + service manifests

## A.5 Security View

Current baseline:

- Input validation in controllers and use cases.
- Hash/salt generation and verification via crypt-compatible adapter.
- Configurable passwd/shadow source paths for sandbox-safe operation.

Recommended next steps:

- Add authorization for mutation endpoints.
- Add immutable audit trail for passwd/shadow changes.
- Add encrypted persistent storage for sequencing datasets.

## A.6 Information View

Core information objects:

- HtsRecord
- IngestSummary
- PasswdEntry
- ShadowEntry
- UnixUser

## A.7 Standards View

Implementation standards:

- Language: D
- HTTP framework: vibe.d
- Architecture: Clean + Hexagonal
- Security hashing: POSIX crypt
- Container format: OCI
- Orchestration: Kubernetes YAML manifests
