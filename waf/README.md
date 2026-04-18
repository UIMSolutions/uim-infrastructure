# UIM WAF Service

A Web Application Firewall (WAF) service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture.

## Architecture

- **Domain**: WAF entities (rules, policies, events) and ports (repository interfaces).
- **Application**: Use cases that enforce business rules.
- **Infrastructure**: HTTP adapter (vibe.d routes) and in-memory repository adapters.

### Layer mapping

- Domain: `source/uim/infrastructure/waf/domain`
- Application: `source/uim/infrastructure/waf/application`
- Infrastructure: `source/uim/infrastructure/waf/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repositories are outbound adapters.

### Concepts

- **Rule**: A pattern-based security rule (SQL injection, XSS, path traversal, rate limiting, IP blacklisting, custom regex) with an action (allow, block, log, challenge).
- **Policy**: A named collection of rules applied in either detection (log-only) or prevention (active blocking) mode.
- **Evaluate**: Inspects a request against a policy's rules and returns allow/block with logged events.
- **Event**: An audit log entry generated when a rule matches during evaluation.

## API

### Health

- `GET /health` - Service health check

### Rules

- `GET /v1/rules` - List all rules
- `POST /v1/rules` - Create a rule (JSON body)
- `GET /v1/rules/<id>` - Get a rule by ID
- `DELETE /v1/rules/<id>` - Delete a rule

Create rule request body:
```json
{
  "name": "Block SQL Injection",
  "pattern": "(?i)(union\\s+select|drop\\s+table|;\\s*delete)",
  "action": "BLOCK",
  "ruleType": "SQL_INJECTION",
  "priority": 1,
  "description": "Blocks common SQL injection patterns"
}
```

### Policies

- `GET /v1/policies` - List all policies
- `POST /v1/policies` - Create a policy (JSON body)
- `GET /v1/policies/<id>` - Get a policy by ID
- `DELETE /v1/policies/<id>` - Delete a policy

Create policy request body:
```json
{
  "name": "Default Protection",
  "ruleIds": ["<rule-id-1>", "<rule-id-2>"],
  "mode": "PREVENTION",
  "description": "Standard WAF protection policy"
}
```

### Evaluate

- `POST /v1/evaluate` - Evaluate an HTTP request against a policy

Evaluate request body:
```json
{
  "policyId": "<policy-id>",
  "sourceIp": "192.168.1.100",
  "requestMethod": "GET",
  "requestPath": "/api/users?id=1 OR 1=1",
  "requestBody": "",
  "headers": {}
}
```

Response (blocked):
```json
{
  "allowed": false,
  "ruleId": "<rule-id>",
  "ruleName": "Block SQL Injection",
  "action": "BLOCK",
  "matchedPattern": "(?i)(union\\s+select|drop\\s+table|;\\s*delete)",
  "eventsGenerated": 1
}
```

### Events

- `GET /v1/events` - List all security events

## Run locally

```bash
cd waf
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd waf
docker build -t uim-waf-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-waf-service uim-waf-service:latest
```

## Podman

Build:

```bash
cd waf
podman build -f Containerfile -t uim-waf-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-waf-service uim-waf-service:latest
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
kubectl -n uim-waf port-forward service/uim-waf-service 8080:80
```

## Test

```bash
cd waf
dub test
```
