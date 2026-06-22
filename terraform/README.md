# uim-terraform-service

A Terraform orchestration microservice built with D and vibe.d, structured around a combination of Clean Architecture and Hexagonal Architecture.

The service follows Terraform's core positioning as infrastructure as code for automation across environments, using one workflow to provision and manage cloud, private datacenter, and SaaS infrastructure through its lifecycle.

## Architecture

```
terraform/
└── source/
    ├── app.d
    └── uim/infrastructure/terraform/
        ├── domain/
        │   ├── entities/terraform_execution.d
        │   └── ports/terraform_runner.d
        ├── application/
        │   ├── dto/terraform_command.d
        │   └── usecases/
        │       ├── get_terraform_version.d
        │       └── run_terraform_action.d
        └── infrastructure/
            ├── cli/terraform_cli_runner.d
            └── http/controllers/terraform.d
```

## HTTP API

| Method | Path | Description |
|---|---|---|
| GET | /health | Liveness and readiness probe |
| GET | /v1/terraform/version | Runs `terraform version` |
| POST | /v1/terraform/validate | Runs `terraform init` and `terraform validate` |
| POST | /v1/terraform/plan | Runs `terraform init` and `terraform plan` |
| POST | /v1/terraform/apply | Runs `terraform init` and `terraform apply` |
| POST | /v1/terraform/destroy | Runs `terraform init` and `terraform destroy` |

### Request body for action endpoints

```json
{
  "command": {
    "workspace": "dev",
    "module_path": "/app/modules/example",
    "auto_approve": true,
    "variables": {
      "environment": "dev"
    }
  }
}
```

## Build and Run

```bash
cd terraform
dub build
./uim-terraform-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| PORT | 8080 | HTTP listen port |
| BIND_ADDRESS | 0.0.0.0 | HTTP bind address |
| TERRAFORM_BINARY | terraform | Terraform executable path |
| TERRAFORM_DEFAULT_MODULE_PATH | /app/modules/example | Default module path when request omits `module_path` |
| TERRAFORM_AUTO_APPROVE | true | Default auto-approve behavior for apply and destroy |

## Containers

Docker:

```bash
docker build -t uim-terraform-service .
docker run -p 8080:8080 uim-terraform-service
```

Podman:

```bash
podman build -t uim-terraform-service .
podman run -p 8080:8080 uim-terraform-service
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Example module

The service image contains a minimal example module in `modules/example/main.tf` so health, validate, and plan endpoints can be exercised without external providers.