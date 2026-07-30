# NAF v4 Views - uim-smtp-relay-service

This document summarizes key NATO Architecture Framework v4 viewpoints for the SMTP relay service.

## C1 Capability Taxonomy

- Messaging Capability
- Outbound SMTP Relay
- Message Validation
- Message Tracking and Audit
- HTTP API Exposure
- MVC Web Interface

## C2 Enterprise Vision

The service provides a cloud-native SMTP relay boundary for platform workloads, with both API-first integration and human-friendly MVC operations.

Goals:

1. Centralize outbound email relay behind one service endpoint.
2. Decouple message intent (use case) from transport details (SMTP adapter).
3. Support multi-platform deployment across OCI containers, CF, and Kubernetes.
4. Expose observable health and message-state behavior.

## Cr Capability Dependencies

- Message Relay depends on SMTP transport adapter.
- Web and API adapters depend on application use cases.
- Use cases depend on repository and relay ports.
- Deployment capabilities depend on OCI runtime or CF scheduler.

## L1 Logical Nodes

- API Client
- Web User
- SMTP Relay Service
- Message Repository Adapter
- SMTP Server (external)

## L2 Logical Scenario (Relay)

1. User/API submits relay request.
2. HTTP adapter maps request to RelayMessageUseCase.
3. Use case validates data and stores queued message.
4. Use case calls SMTP relay port.
5. SMTP adapter relays message to external SMTP server.
6. Use case stores final status (relayed/failed).
7. HTTP adapter returns response or renders page.

## L3 Logical Connectivity

- HTTP/JSON or HTTP/HTML between clients and service.
- In-process calls between adapters and use cases.
- Port interface calls from use cases to repository/SMTP adapters.
- TCP SMTP from adapter to external SMTP endpoint.

## P1 Physical Resource Types

- OCI container image
- Docker runtime / Podman runtime
- Cloud Foundry app container
- Kubernetes Deployment + Service + ConfigMap + Namespace

## P2 Physical Scenario

1. Build binary and image.
2. Deploy image to runtime target.
3. Inject runtime env vars (PORT, SMTP_HOST, SMTP_PORT, SMTP_FROM).
4. Route ingress traffic to HTTP port.
5. Service relays mail to configured SMTP target.

## P3 Physical Connectivity

- Inbound: TCP 8080 (or platform PORT mapping)
- Outbound: TCP to SMTP host/port
- Kubernetes service maps cluster traffic to pod port 8080

## S1 Service Taxonomy

- Health Service: GET /health
- Message Relay Service: POST /api/v1/messages
- Message Query Service: GET /api/v1/messages, GET /api/v1/messages/{id}
- Web UI Service: /, /compose, /messages, /messages/{id}

## S3 Service Interfaces

- HTTP JSON: application/json request/response payloads
- HTTP HTML: text/html server-rendered pages
- SMTP: HELO, MAIL FROM, RCPT TO, DATA, QUIT transaction

## A1 Architecture Overview

The architecture follows strict inward dependencies:

- Domain layer knows nothing about frameworks.
- Application layer orchestrates business use cases via ports.
- Infrastructure layer hosts adapters for web/API, persistence, and SMTP.

This enables replacing SMTP or persistence adapters with minimal effect on use-case code.
