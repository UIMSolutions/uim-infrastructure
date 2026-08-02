# uim-dlang-formatter-service

A D formatter-oriented service implemented with D and vibe.d using Clean and Hexagonal architecture.

Features:

- Format D source snippets through HTTP JSON endpoints.
- Render MVC HTML pages for interactive formatting workflows.
- Use pluggable formatter profiles such as default and check.
- Deployable to Docker, Podman, Cloud Foundry, and Kubernetes.

## Architecture layout

```text
dlang-formatter/
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
    └── uim/infrastructure/dlang_formatter_service/
        ├── domain/
        │   ├── entities/format_result.d
        │   └── ports/formatter/formatter_gateway.d
        ├── application/
        │   ├── dto/format_command.d
        │   └── usecases/
        │       ├── format_source.d
        │       └── list_profiles.d
        └── infrastructure/
            ├── formatter/process_formatter_gateway.d
            └── http/
                ├── controllers/api_controller.d
                ├── controllers/web_controller.d
                └── views/html_renderer.d
```

## JSON API

| Method | Path | Description |
| --- | --- | --- |
| GET | /health | Health check |
| GET | /v1/formatter/profiles | List formatter profiles |
| POST | /v1/formatter/format | Format provided D source |

Format request example:

```json
{
  "sourceCode": "module snippet; void main(){writeln(\"hi\");}",
  "fileName": "snippet.d",
  "profile": "default"
}
```

## MVC HTML routes

| Method | Path | Description |
| --- | --- | --- |
| GET | / | Home and profile catalog |
| GET | /format | Formatter form page |
| POST | /format | Submit source for formatting |

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | Bind address |
| DLANG_FORMATTER | dfmt | Formatter executable name/path |

## Local run

```bash
cd dlang-formatter
dub run
```

## Docker

```bash
docker build -t uim-dlang-formatter-service .
docker run --rm -p 8080:8080 uim-dlang-formatter-service
```

## Podman

```bash
podman build -t uim-dlang-formatter-service .
podman run --rm -p 8080:8080 uim-dlang-formatter-service
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
