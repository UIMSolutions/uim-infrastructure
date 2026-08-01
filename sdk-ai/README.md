# uim-sdk-ai-service

SAP Cloud SDK for AI style service implemented in D and vibe.d with Clean Architecture + Hexagonal Architecture.

The service exposes:

- JSON HTTP APIs for model discovery and chat completion.
- MVC-style HTML UI pages for rendering and interacting with AI endpoints.
- Runtime support for Docker, Podman, Cloud Foundry, and Kubernetes.

## Features

- `GET /health`
- `GET /api/v1/models?tenantId=<id>`
- `POST /api/v1/chat/completions`
- `GET /` and `GET /web` for HTML dashboard rendering

## Architecture

```text
sdk-ai/
├── source/
│   ├── app.d
│   └── uim/infrastructure/sdk_ai/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── chat.d
│       │   │   └── model_info.d
│       │   └── ports/
│       │       └── ai_model_gateway.d
│       ├── application/
│       │   ├── dto/
│       │   │   └── chat_completion_command.d
│       │   └── usecases/
│       │       ├── list_models.d
│       │       └── generate_chat_completion.d
│       └── infrastructure/
│           ├── config/settings.d
│           └── http/
│               ├── clients/sap_ai_gateway.d
│               ├── controllers/
│               │   ├── ai_api_controller.d
│               │   └── web_controller.d
│               └── views/dashboard_view.d
├── Dockerfile
├── Containerfile
├── manifest.yml
└── k8s/
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | HTTP port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `AI_PROVIDER` | `sap-ai-core` | Provider label returned in responses |
| `AI_BASE_URL` | empty | Remote AI endpoint base URL |
| `AI_API_KEY` | empty | Bearer token for remote AI endpoint |
| `AI_RESOURCE_GROUP` | `default` | SAP AI resource group header value |
| `AI_DEPLOYMENT_ID` | `default` | Deployment ID header value |
| `DEFAULT_TENANT_ID` | `default` | Fallback tenant ID |

If `AI_BASE_URL` and `AI_API_KEY` are missing, the service uses local fallback responses to keep local development productive.

## Build and Run

```bash
cd sdk-ai
dub build
./uim-sdk-ai-service
```

## Docker

```bash
docker build -t uim-sdk-ai-service .
docker run -p 8080:8080 \
  -e AI_BASE_URL=https://your-ai-endpoint.example.com \
  -e AI_API_KEY=token \
  uim-sdk-ai-service
```

## Podman

```bash
podman build -t uim-sdk-ai-service .
podman run -p 8080:8080 \
  -e AI_BASE_URL=https://your-ai-endpoint.example.com \
  -e AI_API_KEY=token \
  uim-sdk-ai-service
```

## Cloud Foundry

```bash
cf push -f manifest.yml
```

To call a remote SAP AI endpoint in CF:

```bash
cf set-env uim-sdk-ai-service AI_BASE_URL https://your-ai-endpoint.example.com
cf set-env uim-sdk-ai-service AI_API_KEY your-token
cf restage uim-sdk-ai-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Example API Request

```bash
curl -X POST http://localhost:8080/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "default",
    "model": "gpt-4o-mini",
    "temperature": 0.2,
    "max_tokens": 256,
    "messages": [
      {"role": "user", "content": "Explain hexagonal architecture in 3 bullets."}
    ]
  }'
```
