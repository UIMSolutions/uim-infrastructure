# NAF v4 - uim-dlang-formatter-service

## A.1 Capability View

Capability delivered:

- D source formatting service with profile-aware execution.
- API-first integration and browser-friendly MVC workflows.

## A.2 Logical View

Primary logical components:

- Formatter API Controller
- Formatter Web Controller
- Format Source Use Case
- List Profiles Use Case
- Formatter Gateway Port
- Process-based Formatter Adapter

## A.3 Service View

Exposed services:

- JSON endpoints under /v1/formatter/*.
- HTML endpoints under / and /format.

## A.4 Deployment View

Deployment targets:

- Native binary process
- Docker/Podman OCI container
- Cloud Foundry binary app
- Kubernetes deployment and service manifests

## A.5 Security View

Current baseline:

- Input validation for format requests.
- Explicit profile mapping to constrain formatter invocation shape.

Recommended next steps:

- Add tenant authentication and request quotas.
- Add sandboxing and syscall restrictions for formatter workers.
- Add per-request resource limits and execution timeouts.

## A.6 Information View

Core information objects:

- FormatRequest
- FormatResult
- FormatterProfile

## A.7 Standards View

Implementation standards:

- Language: D
- HTTP framework: vibe.d
- Architecture: Clean + Hexagonal
- Container format: OCI
- Orchestration: Kubernetes manifests
