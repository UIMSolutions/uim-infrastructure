# UIM Ansible Automation Service

An Ansible-like automation service built with D + vibe.d using a blend of Clean Architecture and Hexagonal Architecture. Manage hosts, inventories, tasks, and playbooks, then execute playbooks against inventories to automate infrastructure operations.

## Architecture

- **Domain**: Entities (hosts, inventories, tasks, playbooks, executions) and ports (repository interfaces).
- **Application**: Use cases that enforce business rules and orchestrate operations.
- **Infrastructure**: HTTP adapter (vibe.d routes) and in-memory repository adapters.

### Layer mapping

- Domain: `source/uim/infrastructure/ansible/domain`
- Application: `source/uim/infrastructure/ansible/application`
- Infrastructure: `source/uim/infrastructure/ansible/infrastructure`
- Composition root: `source/app.d`

The HTTP layer is an inbound adapter and the repositories are outbound adapters.

### Concepts

- **Host**: A managed machine with hostname, IP, port, user, status, and variables.
- **Inventory**: A named collection of host groups for organizing infrastructure.
- **Task**: An atomic unit of work using a module (command, shell, copy, template, package, service, file, user, lineinfile, custom).
- **Playbook**: An ordered set of plays, each targeting a host group with a list of tasks.
- **Execution**: The result of running a playbook against an inventory, with per-task/per-host results.

## API

### Health

- `GET /health` - Service health check

### Hosts

- `GET /v1/hosts` - List all hosts
- `POST /v1/hosts` - Create a host
- `GET /v1/hosts/<id>` - Get a host by ID
- `DELETE /v1/hosts/<id>` - Delete a host

Create host request body:
```json
{
  "hostname": "web01",
  "ipAddress": "10.0.0.1",
  "port": 22,
  "user": "root",
  "variables": { "env": "production" }
}
```

### Inventories

- `GET /v1/inventories` - List all inventories
- `POST /v1/inventories` - Create an inventory
- `GET /v1/inventories/<id>` - Get an inventory by ID
- `DELETE /v1/inventories/<id>` - Delete an inventory

Create inventory request body:
```json
{
  "name": "production",
  "description": "Production servers",
  "groups": [
    {
      "name": "web",
      "hostIds": ["<host-id-1>", "<host-id-2>"],
      "groupVars": { "http_port": "80" }
    }
  ]
}
```

### Tasks

- `GET /v1/tasks` - List all tasks
- `POST /v1/tasks` - Create a task
- `GET /v1/tasks/<id>` - Get a task by ID
- `DELETE /v1/tasks/<id>` - Delete a task

Create task request body:
```json
{
  "name": "Install nginx",
  "taskModule": "PACKAGE",
  "parameters": { "name": "nginx", "state": "present" },
  "ignoreErrors": false,
  "when": ""
}
```

### Playbooks

- `GET /v1/playbooks` - List all playbooks
- `POST /v1/playbooks` - Create a playbook
- `GET /v1/playbooks/<id>` - Get a playbook by ID
- `DELETE /v1/playbooks/<id>` - Delete a playbook

Create playbook request body:
```json
{
  "name": "Deploy Web Server",
  "description": "Install and configure nginx",
  "plays": [
    {
      "name": "Install packages",
      "targetGroup": "web",
      "taskIds": ["<task-id-1>"],
      "vars": { "http_port": "80" },
      "become": true
    }
  ]
}
```

### Run Playbook

- `POST /v1/run` - Execute a playbook against an inventory

Run request body:
```json
{
  "playbookId": "<playbook-id>",
  "inventoryId": "<inventory-id>"
}
```

Response:
```json
{
  "id": "<execution-id>",
  "playbookId": "<playbook-id>",
  "playbookName": "Deploy Web Server",
  "inventoryId": "<inventory-id>",
  "status": "SUCCESS",
  "results": [
    {
      "taskId": "<task-id>",
      "taskName": "Install nginx",
      "hostId": "<host-id>",
      "hostname": "web01",
      "changed": true,
      "failed": false,
      "output": "Simulated execution of PACKAGE on web01",
      "error": ""
    }
  ],
  "startedAt": "2026-04-18T10:00:00Z",
  "finishedAt": "2026-04-18T10:00:01Z"
}
```

### Executions

- `GET /v1/executions` - List all executions
- `GET /v1/executions/<id>` - Get execution details

## Run locally

```bash
cd ansible
dub run
```

Environment variables:
- `PORT` (default: 8080)
- `BIND_ADDRESS` (default: 0.0.0.0)

## Docker

Build:

```bash
cd ansible
docker build -t uim-ansible-service:latest .
```

Run:

```bash
docker run --rm -p 8080:8080 --name uim-ansible-service uim-ansible-service:latest
```

## Podman

Build:

```bash
cd ansible
podman build -f Containerfile -t uim-ansible-service:latest .
```

Run:

```bash
podman run --rm -p 8080:8080 --name uim-ansible-service uim-ansible-service:latest
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
kubectl -n uim-ansible port-forward service/uim-ansible-service 8080:80
```

## Test

```bash
cd ansible
dub test
```
