# NAF v4 - uim-acdoca-service

## A.1 Capability View

Capability delivered:
- Universal journal style posting and inspection of accounting line items.
- API-first integration with optional browser-based operation.

## A.2 Logical View

Primary logical components:
- Journal API Controller
- Journal Web Controller
- Journal Entry Use Cases
- Journal Entry Repository Port
- In-Memory Repository Adapter
- PostgreSQL Repository Adapter
- Write Auth Middleware (Bearer/JWT/OAuth2 modes)

## A.3 Service View

Exposed services:
- JSON endpoints under `/v1/journal-entries`.
- HTML endpoints under `/entries` and `/`.

## A.4 Deployment View

Deployment targets:
- Native binary process
- Docker/Podman container
- Cloud Foundry app via binary buildpack
- Kubernetes workload via deployment/service manifests

## A.5 Security View

Current baseline:
- Input validation at controller and use-case layers.
- AuthN/AuthZ middleware for write operations with configurable Bearer, JWT, and OAuth2 token-map modes.

Recommended next steps:
- Add role checks for create/delete operations.
- Add audit logging for posting and deletion.

## A.6 Information View

Core information objects:
- JournalEntry
- DebitCreditIndicator

## A.7 Standards View

Implementation standards:
- Language: D
- HTTP framework: vibe.d
- Architectural principles: Clean + Hexagonal
- Container format: OCI
- Orchestration: Kubernetes manifests
