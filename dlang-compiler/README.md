# uim-dlang-compiler-service

A D compiler-oriented service implemented with D and vibe.d using Clean and Hexagonal architecture.

Features:

- Compile D source snippets through HTTP JSON endpoints.
- Render MVC HTML pages for interactive compile workflows.
- Use pluggable compile profiles such as debug and release.
- Deployable to Docker, Podman, Cloud Foundry, and Kubernetes.

## Architecture layout

```text
dlang-compiler/
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
    └── uim/infrastructure/dlang_compiler_service/
        ├── domain/
        │   ├── entities/compile_result.d
        │   └── ports/compiler/compiler_gateway.d
        ├── application/
        │   ├── dto/compile_command.d
        │   └── usecases/
        │       ├── compile_source.d
        │       └── list_profiles.d
        └── infrastructure/
            ├── compiler/process_compiler_gateway.d
            └── http/
                ├── controllers/api_controller.d
                ├── controllers/web_controller.d
                └── views/html_renderer.d
```

## JSON API

| Method | Path | Description |
| --- | --- | --- |
| GET | /health | Health check |
| GET | /v1/compiler/profiles | List compiler profiles |
| POST | /v1/compiler/compile | Compile provided D source |

Compile request example:

```json
{
  "sourceCode": "module snippet; void main() {}",
  "fileName": "snippet.d",
  "profile": "debug"
}
```

## MVC HTML routes

| Method | Path | Description |
| --- | --- | --- |
| GET | / | Home and profile catalog |
| GET | /compile | Compile form page |
| POST | /compile | Submit source for compilation |

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | Bind address |
| DLANG_COMPILER | dmd | Compiler executable name/path |

## Local run

```bash
cd dlang-compiler
dub run
```

## Docker

```bash
docker build -t uim-dlang-compiler-service .
docker run --rm -p 8080:8080 uim-dlang-compiler-service
```

## Podman

```bash
podman build -t uim-dlang-compiler-service .
podman run --rm -p 8080:8080 uim-dlang-compiler-service
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
