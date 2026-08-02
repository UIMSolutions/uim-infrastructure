# NAF v4 - uim-dlang-compiler-service

## A.1 Capability View

Capability delivered:

- D source compilation service with profile-aware execution.
- API-first integration and browser-friendly MVC workflows.

## A.2 Logical View

Primary logical components:

- Compiler API Controller
- Compiler Web Controller
- Compile Source Use Case
- List Profiles Use Case
- Compiler Gateway Port
- Process-based Compiler Adapter

## A.3 Service View

Exposed services:

- JSON endpoints under /v1/compiler/*.
- HTML endpoints under / and /compile.

## A.4 Deployment View

Deployment targets:

- Native binary process
- Docker/Podman OCI container
- Cloud Foundry binary app
- Kubernetes deployment and service manifests

## A.5 Security View

Current baseline:

- Input validation for compile requests.
- Explicit profile mapping to constrain compiler invocation shape.

Recommended next steps:

- Add tenant authentication and compile quotas.
- Add sandboxing and syscall restrictions for compile workers.
- Add per-request resource limits and execution timeouts.

## A.6 Information View

Core information objects:

- CompileRequest
- CompileResult
- CompilerProfile

## A.7 Standards View

Implementation standards:

- Language: D
- HTTP framework: vibe.d
- Architecture: Clean + Hexagonal
- Container format: OCI
- Orchestration: Kubernetes manifests
