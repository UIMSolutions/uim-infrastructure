# NAF v4 - uim-cds-service

This document maps the service architecture to NAF v4 style viewpoints.

## A.1 Capability View

**Capability:** Manage CDS-style data model definitions.

**Delivered outcomes:**
- Create and maintain model definitions.
- Render model definitions as CDS-like source text.
- Serve both machine API and user-facing HTML workflows.

## A.2 Logical View

Logical components:
- **CDS API Controller**: JSON contract for automation.
- **CDS Web Controller**: MVC workflow for browser users.
- **Definition Use Cases**: orchestration and validation logic.
- **Definition Repository Port**: persistence abstraction.
- **InMemory Repository Adapter**: concrete persistence.

## A.3 Service View

Service interfaces:
- HTTP JSON service at `/v1/definitions`.
- HTTP HTML service at `/` and `/definitions/*`.

Protocol and format:
- JSON for API endpoints.
- HTML for MVC pages.

## A.4 Deployment View

Supported runtime targets:
- Native process: `dub run` or compiled binary.
- Container runtime: Docker or Podman.
- Cloud Foundry: `manifest.yml` using binary buildpack.
- Kubernetes: namespace, configmap, deployment, service manifests.

## A.5 Security View

Current baseline:
- No built-in authentication/authorization in this scaffold.
- Input validation in use-cases and controllers.

Recommended hardening:
- Add authentication middleware (JWT/OAuth2).
- Add role-based controls for write endpoints.
- Enable request logging with sensitive-field masking.

## A.6 Information View

Core information objects:
- `CdsDefinition`
- `CdsField`

Key attributes:
- Definition identity, namespace, name, version, lifecycle flag.
- Field name, field type, key marker, nullability.

## A.7 Standards View

Implementation standards:
- Language: D
- Web framework: vibe.d
- Architecture style: Clean + Hexagonal
- Containerization: OCI-compatible Dockerfile/Containerfile
- Orchestration: Kubernetes manifests
