# NAF v4 - uim-unix-auth-service

## A.1 Capability View

Capability delivered:

- Manage POSIX account metadata (`passwd`) and authentication hashes (`shadow`).
- Generate and verify crypt-compatible password hashes.
- Support browser-based operations through MVC pages and automation through JSON API.

## A.2 Logical View

Primary logical components:

- UNIX Auth API Controller
- UNIX Auth Web Controller
- User and Password Use Cases
- UNIX Auth Repository Port
- File Repository Adapter (`/etc/passwd`, `/etc/shadow`)
- Crypt Password Adapter

## A.3 Service View

Exposed services:

- JSON endpoints under `/v1/unix/*`.
- HTML endpoints under `/users/*`, `/hash`, and `/`.

## A.4 Deployment View

Deployment targets:

- Native binary process
- Docker/Podman container
- Cloud Foundry app via binary buildpack
- Kubernetes workload via deployment/service manifests

## A.5 Security View

Current baseline:

- Input validation in controllers and use cases.
- Password processing via libc `crypt` and generated UNIX-compatible salts.
- Supports file path override for least-risk sandbox operation.

Recommended next steps:

- Add role-based authorization for create and password-update operations.
- Add audit logs for each passwd/shadow mutation.
- Add backup/rollback mechanism before writing modified auth files.

## A.6 Information View

Core information objects:

- `PasswdEntry`
- `ShadowEntry`
- `UnixUser`

## A.7 Standards View

Implementation standards:

- Language: D
- HTTP framework: vibe.d
- Architectural principles: Clean + Hexagonal
- Hashing API: POSIX `crypt`
- Container format: OCI
- Orchestration: Kubernetes manifests
