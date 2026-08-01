# NAFv4 - Architecture Mapping for uim-sdk-ai-service

This file maps the service design to NAFv4 viewpoints.

## 1. Capability View

- AI model catalog capability via `/api/v1/models`.
- AI text generation capability via `/api/v1/chat/completions`.
- Human interaction capability via rendered MVC web page (`/web`).

## 2. Operational View

- Stateless service process (`uim-sdk-ai-service`) listens on `PORT`.
- Exposes HTTP northbound interface for API and web rendering.
- Consumes southbound AI provider endpoint via HTTPS (`AI_BASE_URL`).
- Health endpoint `/health` supports readiness/liveness checks.

## 3. Service-Oriented View

- Inbound ports (controllers):
  - `AiApiController`
  - `WebController`
- Application services (use cases):
  - `ListModelsUseCase`
  - `GenerateChatCompletionUseCase`
- Outbound port:
  - `IAiModelGateway`
- Outbound adapter:
  - `SapAiGateway`

## 4. Resource View

- Runtime resources:
  - CPU/memory constrained through Kubernetes deployment spec.
  - Environment variables from ConfigMap and Cloud Foundry manifest.
- Build resource:
  - `dmd:2.111.0` image for container builds.

## 5. Security View

- API key held in environment variable `AI_API_KEY`.
- Provider token propagated as `Authorization: Bearer <token>`.
- Tenant and deployment context passed as headers:
  - `X-Tenant-Id`
  - `X-Resource-Group`
  - `X-Deployment-Id`

## 6. Standards View

- HTTP/JSON request-response style for API.
- MVC rendering over HTML5 for operational console page.
- Deployment standards covered:
  - OCI (Docker/Podman)
  - Cloud Foundry manifest deployment
  - Kubernetes manifests
