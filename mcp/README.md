# uim-mcp-service

A Model Context Protocol (MCP) inspired microservice built with D and vibe.d, structured around a combination of Clean Architecture and Hexagonal Architecture.

This service is aligned with SAP LeanIX Getting Started guidance:
https://help.sap.com/docs/leanix/ea/getting-started?hsCtaAttrib=194319802689&locale=en-US

The implementation exposes MCP-style tools, resources, and prompts around LeanIX concepts such as fact sheets, meta model, collaboration workflows, and roadmap planning.

## Architecture

```
mcp/
└── source/
    ├── app.d
    └── uim/infrastructure/mcp/
        ├── domain/
        │   ├── entities/mcp_primitives.d
        │   └── ports/mcp_registry.d
        ├── application/
        │   ├── dto/server_info.d
        │   └── usecases/
        │       ├── initialize_server.d
        │       ├── list_tools.d
        │       ├── call_tool.d
        │       ├── list_resources.d
        │       └── list_prompts.d
        └── infrastructure/
            ├── registry/memory_registry.d
            └── http/controllers/mcp.d
```

## API

### Health

- `GET /health`

### JSON-RPC (MCP style)

- `POST /mcp`
- `POST /v1/mcp`

Supported methods:
- `initialize`
- `tools/list`
- `tools/call`
- `resources/list`
- `prompts/list`

### Included LeanIX-oriented tools

- `leanix-overview`
- `leanix-fact-sheet-template`
- `leanix-roadmap-checklist`

### Included resources

- `mcp://leanix/introduction`
- `mcp://leanix/key-concepts`
- `mcp://leanix/products`

### Included prompts

- `leanix-workspace-bootstrap`
- `leanix-collaboration-cadence`

Example request:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "leanix-fact-sheet-template",
    "arguments": {
      "factSheetType": "Application",
      "name": "Order Management",
      "owner": "enterprise.architecture@example.com",
      "lifecycle": "active"
    }
  }
}
```

## Build and Run

```bash
cd mcp
dub build
./uim-mcp-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | HTTP bind address |
| MCP_SERVER_NAME | uim-mcp-service | Advertised MCP server name |
| MCP_SERVER_VERSION | 0.1.0 | Advertised MCP server version |

## Containers

Docker:

```bash
docker build -t uim-mcp-service .
docker run -p 8080:8080 uim-mcp-service
```

Podman:

```bash
podman build -t uim-mcp-service .
podman run -p 8080:8080 uim-mcp-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
