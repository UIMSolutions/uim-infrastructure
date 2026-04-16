# uim-vpc-service

A VPC (Virtual Private Cloud) service built with **D** and **vibe.d**, following a clean **hexagonal (ports-and-adapters) architecture**.

## Architecture

```
vpc/
├── dub.sdl
├── Dockerfile / Containerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── source/
    ├── app.d                              ← entry point / wiring
    └── uim/infrastructure/vpc/
        ├── domain/                        ← pure business rules
        │   ├── entities/
        │   │   ├── vpc.d                  ← Vpc struct + VpcState enum
        │   │   └── subnet.d               ← Subnet struct + SubnetState alias
        │   └── ports/
        │       └── repositories/
        │           ├── vpc.d              ← IVpcRepository interface
        │           └── subnet.d           ← ISubnetRepository interface
        ├── application/                   ← use cases / orchestration
        │   ├── dto/
        │   │   └── vpc_commands.d         ← CreateVpcCommand, DeleteVpcCommand,
        │   │                                 CreateSubnetCommand, DeleteSubnetCommand
        │   └── usecases/
        │       ├── create_vpc.d
        │       ├── delete_vpc.d
        │       ├── list_vpcs.d
        │       ├── get_vpc.d
        │       ├── create_subnet.d
        │       ├── delete_subnet.d
        │       └── list_subnets.d
        └── infrastructure/                ← adapters (HTTP, persistence)
            ├── http/controllers/
            │   └── vpc.d                  ← HTTP controller
            └── persistence/memory/
                ├── vpc_repository.d       ← in-memory IVpcRepository
                └── subnet_repository.d    ← in-memory ISubnetRepository
```

### Hexagonal layers

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| **Domain** | `Vpc`/`Subnet` entities, repository ports | none |
| **Application** | Use-case orchestration, DTOs | Domain only |
| **Infrastructure** | HTTP controller, in-memory persistence adapters | Application + vibe.d |

## HTTP API

### VPCs

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Liveness check |
| `GET` | `/v1/vpcs` | List all VPCs |
| `POST` | `/v1/vpcs/<id>/<name>/<cidr>/<region>` | Create a VPC |
| `DELETE` | `/v1/vpcs/<id>` | Delete a VPC |

### Subnets

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/v1/subnets` | List all subnets |
| `GET` | `/v1/vpcs/<vpcId>/subnets` | List subnets for a VPC |
| `POST` | `/v1/vpcs/<vpcId>/subnets/<id>/<name>/<cidr>/<az>` | Create a subnet in a VPC |
| `DELETE` | `/v1/subnets/<id>` | Delete a subnet |

### Examples

```bash
# Create a VPC
curl -X POST http://localhost:8080/v1/vpcs/vpc-001/production/10.0.0.0%2F16/eu-west-1

# List all VPCs
curl http://localhost:8080/v1/vpcs

# Create a subnet inside a VPC
curl -X POST http://localhost:8080/v1/vpcs/vpc-001/subnets/subnet-001/public-a/10.0.1.0%2F24/eu-west-1a

# List subnets of a VPC
curl http://localhost:8080/v1/vpcs/vpc-001/subnets

# Delete a subnet
curl -X DELETE http://localhost:8080/v1/subnets/subnet-001

# Delete a VPC
curl -X DELETE http://localhost:8080/v1/vpcs/vpc-001
```

> **Note:** URL-encode the `/` in CIDR notation as `%2F` when passing it as a path segment.

## Building

```bash
cd vpc
dub build
./uim-vpc-service
```

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Listening port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |

## Docker

```bash
docker build -t uim-vpc-service .
docker run -p 8080:8080 uim-vpc-service
```

## Podman

```bash
podman build -f Containerfile -t uim-vpc-service:latest .
podman run --rm -p 8080:8080 --name uim-vpc-service uim-vpc-service:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Access from cluster tooling:

```bash
kubectl -n uim-vpc port-forward service/uim-vpc-service 8080:80
```

## Test

```bash
cd vpc
dub test
```
