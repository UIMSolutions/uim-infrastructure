# UIM Crossplane Infrastructure Composition Service

A Crossplane-like infrastructure composition service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture. Define providers, compose infrastructure from templates, submit claims, and reconcile them into managed resources.

## Architecture

- **Domain**: Entities (providers, compositions, managed resources, claims, composite resources) and ports (repository interfaces).
- **Application**: Use cases that enforce business rules and orchestrate reconciliation.
- **Infrastructure**: HTTP adapter (vibe.d routes) and in-memory repository adapters.

### Layer mapping

- Domain: `source/uim/infrastructure/crossplane/domain`
- Application: `source/uim/infrastructure/crossplane/application`
- Infrastructure: `source/uim/infrastructure/crossplane/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repositories are outbound adapters.

### Concepts

- **Provider**: A cloud provider configuration (AWS, GCP, Azure, Kubernetes, Helm, Terraform, custom) with credentials and region.
- **Composition**: A template that defines how to compose multiple managed resources from a single claim. Contains composed templates with base specs and patches.
- **Managed Resource**: An individual infrastructure resource (S3 bucket, RDS instance, etc.) with status and readiness tracking.
- **Claim**: A user-facing request for infrastructure, referencing a composition. Gets bound to a composite resource after reconciliation.
- **Composite Resource (XR)**: The result of reconciling a claim against a composition. Contains references to all created managed resources.
- **Reconcile**: The core operation that takes a pending claim, looks up its composition, creates the necessary managed resources, assembles a composite resource, and binds the claim.

## API

### Health

- `GET /health` - Service health check

### Providers

- `GET /v1/providers` - List all providers
- `POST /v1/providers` - Create a provider
- `GET /v1/providers/<id>` - Get a provider by ID
- `DELETE /v1/providers/<id>` - Delete a provider

Create provider request body:
```json
{
  "name": "aws-provider",
  "providerType": "AWS",
  "packageRef": "crossplane/provider-aws:v0.30",
  "region": "us-east-1",
  "credentials": [
    { "key": "aws-creds", "secretRef": "aws-secret" }
  ],
  "config": { "assumeRoleArn": "arn:aws:iam::role/crossplane" }
}
```

### Compositions

- `GET /v1/compositions` - List all compositions
- `POST /v1/compositions` - Create a composition
- `GET /v1/compositions/<id>` - Get a composition by ID
- `DELETE /v1/compositions/<id>` - Delete a composition

Create composition request body:
```json
{
  "name": "s3-with-policy",
  "compositeTypeRef": "XObjectStorage",
  "resources": [
    {
      "name": "bucket",
      "kind": "Bucket",
      "apiGroup": "s3.aws.crossplane.io",
      "base": { "region": "us-east-1" },
      "patches": {}
    },
    {
      "name": "policy",
      "kind": "BucketPolicy",
      "apiGroup": "s3.aws.crossplane.io",
      "base": {},
      "patches": {}
    }
  ]
}
```

### Managed Resources

- `GET /v1/managed-resources` - List all managed resources
- `POST /v1/managed-resources` - Create a managed resource
- `GET /v1/managed-resources/<id>` - Get a managed resource by ID
- `DELETE /v1/managed-resources/<id>` - Delete a managed resource

Create managed resource request body:
```json
{
  "name": "my-s3-bucket",
  "providerId": "<provider-id>",
  "apiGroup": "s3.aws.crossplane.io",
  "kind": "Bucket",
  "spec": { "region": "us-east-1", "bucketName": "my-bucket" }
}
```

### Claims

- `GET /v1/claims` - List all claims
- `POST /v1/claims` - Create a claim
- `GET /v1/claims/<id>` - Get a claim by ID
- `DELETE /v1/claims/<id>` - Delete a claim

Create claim request body:
```json
{
  "name": "my-storage",
  "namespace": "team-a",
  "compositionRef": "<composition-id>",
  "parameters": { "region": "us-east-1", "storageSize": "100Gi" }
}
```

### Reconcile

- `POST /v1/reconcile` - Reconcile a claim into a composite resource

Reconcile request body:
```json
{
  "claimId": "<claim-id>"
}
```

Response:
```json
{
  "id": "<composite-resource-id>",
  "name": "my-storage-xr",
  "compositionId": "<composition-id>",
  "claimId": "<claim-id>",
  "status": "READY",
  "resourceRefs": [
    {
      "resourceId": "<managed-resource-id>",
      "name": "bucket",
      "kind": "Bucket",
      "ready": "TRUE"
    }
  ],
  "createdAt": "2026-04-19T10:00:00Z",
  "updatedAt": "2026-04-19T10:00:01Z"
}
```

### Composite Resources

- `GET /v1/composite-resources` - List all composite resources
- `GET /v1/composite-resources/<id>` - Get composite resource details

## Run locally

```bash
cd crossplane
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd crossplane
docker build -t uim-crossplane-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-crossplane-service uim-crossplane-service:latest
```

## Podman

Build:

```bash
cd crossplane
podman build -f Containerfile -t uim-crossplane-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-crossplane-service uim-crossplane-service:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Access from cluster tooling:

```bash
kubectl -n uim-crossplane port-forward service/uim-crossplane-service 8080:80
```

## Test

```bash
cd crossplane
dub test
```
