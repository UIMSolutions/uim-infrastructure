# NAF v4 Architecture Views – uim-block-storage-service

This document presents the key NATO Architecture Framework v4 (NAF v4) viewpoints for the **uim-block-storage-service**.

---

## NAF v4 Overview

NAF v4 organises architecture descriptions into **viewpoints** grouped under the MODAF/TOGAF-aligned grid:

| Grid Cell | Viewpoint | Focus |
|---|---|---|
| **C1** | Capability Taxonomy | Capabilities the architecture provides |
| **C2** | Enterprise Vision | Strategic context and goals |
| **Cr** | Capability Dependencies | How capabilities relate to each other |
| **L1** | Node Types | Logical nodes / services |
| **L2** | Logical Scenario | Behaviour / interactions between nodes |
| **L3** | Node Connectivity | Logical communication paths |
| **P1** | Resource Types | Physical / deployment nodes |
| **P2** | Resource Scenario | Physical behaviour / data flows |
| **P3** | Resource Connectivity | Physical network links |
| **S1** | Service Taxonomy | Services provided by the architecture |
| **S3** | Service Interfaces | Interface specifications |
| **Sv1** | Service Orientation | How services are composed |
| **A1** | Architecture Overview | Overview of all views |

---

## C1 – Capability Taxonomy

```
Block Storage Capability
├── Volume Lifecycle Management
│   ├── Create Volume
│   ├── Delete Volume
│   └── Get / List Volumes
└── Volume Attachment Management
    ├── Attach Volume to Compute Instance
    └── Detach Volume from Compute Instance
```

**Description:** The block-storage service provides persistent block-level storage volumes that can be dynamically provisioned, attached to, and detached from compute instances.

---

## C2 – Enterprise Vision

**Strategic Context:** Cloud-native infrastructure platform for UIM Solutions.

**Goals:**
1. Provide persistent, high-availability block storage volumes to compute workloads.
2. Expose a language-agnostic REST API for volume lifecycle management.
3. Integrate seamlessly with container orchestration (Kubernetes) and container runtimes (Docker, Podman).
4. Support process supervision (pidman, systemd, runit) for reliability.
5. Enable horizontal scalability via stateless service instances backed by a shared storage adapter.

---

## Cr – Capability Dependencies

```
[Volume Lifecycle Management] ──────────────── depends on ──▶ [Persistence Adapter]
[Volume Attachment Management] ─── depends on ──▶ [Volume Lifecycle Management]
[REST API] ──────────────────── exposes ────────▶ [Volume Lifecycle Management]
                                                  [Volume Attachment Management]
[Kubernetes / Docker] ────────── hosts ─────────▶ [REST API]
[pidman / systemd] ──────────── supervises ──────▶ [REST API]
```

---

## L1 – Node Types (Logical Nodes)

| Node | Type | Description |
|---|---|---|
| **BlockStorageService** | Logical Service Node | The vibe.d HTTP service exposing the REST API |
| **VolumeStore** | Logical Data Node | Repository of block volumes (port `IBlockVolumeRepository`) |
| **ComputeInstance** | External Logical Node | Compute workload that attaches a volume |
| **APIClient** | External Logical Node | Any HTTP client consuming the REST API |

---

## L2 – Logical Scenario: Create and Attach a Volume

```
APIClient                  BlockStorageService          VolumeStore
    │                              │                          │
    │── POST /v1/volumes ─────────▶│                          │
    │                              │── CreateVolumeUseCase ──▶│
    │                              │   save(volume)            │
    │                              │◀── ok ───────────────────│
    │◀── 201 { id, state:available}│                          │
    │                              │                          │
    │── POST /v1/volumes/{id}/attach▶                         │
    │                              │── AttachVolumeUseCase ──▶│
    │                              │   findById(id)            │
    │                              │◀── BlockVolume ──────────│
    │                              │   save(updated)           │
    │                              │◀── ok ───────────────────│
    │◀── 200 { state:attached } ───│                          │
```

---

## L3 – Node Connectivity (Logical)

```
[APIClient]
    │  HTTP/REST (JSON)
    ▼
[BlockStorageService]
    │  D interface call (IBlockVolumeRepository)
    ▼
[VolumeStore (InMemoryBlockVolumeRepository)]
```

> **Note:** For production deployments the in-memory adapter is replaced with a durable persistence adapter (e.g., backed by a distributed block store or database), while the logical connectivity remains unchanged.

---

## P1 – Resource Types (Physical / Deployment Nodes)

| Resource | Type | Description |
|---|---|---|
| **Container Image** | OCI image | `uim-block-storage-service:latest` built from `Dockerfile` / `Containerfile` |
| **Kubernetes Pod** | Compute resource | Runs the container; 2 replicas by default |
| **Kubernetes Deployment** | Workload resource | Manages pod lifecycle, rolling updates |
| **Kubernetes Service (ClusterIP)** | Network resource | Stable internal endpoint on port 80 → 8080 |
| **Kubernetes ConfigMap** | Config resource | `PORT`, `BIND_ADDRESS`, `PID_FILE` |
| **Kubernetes Namespace** | Isolation resource | `uim-block-storage` |

---

## P2 – Resource Scenario: Kubernetes Deployment

```
Developer
  │
  │  kubectl apply -f k8s/
  ▼
Kubernetes API Server
  │
  ├──▶ Namespace: uim-block-storage
  ├──▶ ConfigMap: block-storage-service-config
  ├──▶ Deployment: uim-block-storage-service
  │       replicas: 2
  │       image: uim-block-storage-service:latest
  │       envFrom: block-storage-service-config
  │       readinessProbe: GET /health
  │       livenessProbe:  GET /health
  └──▶ Service: uim-block-storage-service (ClusterIP :80 → Pod :8080)
```

---

## P3 – Resource Connectivity (Physical Network)

```
[Ingress / LoadBalancer]
    │  :443 / :80  (external)
    ▼
[Kubernetes Service: uim-block-storage-service]  :80
    │  ClusterIP routing
    ▼
[Pod 1: block-storage container]  :8080
[Pod 2: block-storage container]  :8080
```

---

## S1 – Service Taxonomy

```
uim-block-storage-service
└── REST API (vibe.d HTTP)
    ├── HealthService
    │   └── GET /health
    ├── VolumeLifecycleService
    │   ├── POST   /v1/volumes          (Create)
    │   ├── GET    /v1/volumes          (List)
    │   ├── GET    /v1/volumes/{id}     (Get)
    │   └── DELETE /v1/volumes/{id}     (Delete)
    └── VolumeAttachmentService
        ├── POST   /v1/volumes/{id}/attach
        └── POST   /v1/volumes/{id}/detach
```

---

## S3 – Service Interfaces

### HealthService

| Attribute | Value |
|---|---|
| Endpoint | `GET /health` |
| Response | `200 OK` `{ "status": "ok" }` |
| Content-Type | `application/json` |

### VolumeLifecycleService

**Create Volume**

| Attribute | Value |
|---|---|
| Endpoint | `POST /v1/volumes` |
| Request Body | `{ "name": string, "sizeGiB": number }` |
| Response 201 | `BlockVolumeView` |
| Response 400 | `{ "error": string }` |

**List Volumes**

| Attribute | Value |
|---|---|
| Endpoint | `GET /v1/volumes` |
| Response 200 | `BlockVolumeView[]` |

**Get Volume**

| Attribute | Value |
|---|---|
| Endpoint | `GET /v1/volumes/{id}` |
| Response 200 | `BlockVolumeView` |
| Response 404 | `{ "error": "volume not found" }` |

**Delete Volume**

| Attribute | Value |
|---|---|
| Endpoint | `DELETE /v1/volumes/{id}` |
| Response 204 | _(empty body)_ |
| Response 400 | `{ "error": "cannot delete an attached volume; detach it first" }` |

### VolumeAttachmentService

**Attach Volume**

| Attribute | Value |
|---|---|
| Endpoint | `POST /v1/volumes/{id}/attach` |
| Request Body | `{ "instanceId": string }` |
| Response 200 | `BlockVolumeView` (state: `attached`) |
| Response 400 | `{ "error": string }` |

**Detach Volume**

| Attribute | Value |
|---|---|
| Endpoint | `POST /v1/volumes/{id}/detach` |
| Response 200 | `BlockVolumeView` (state: `available`) |
| Response 400 | `{ "error": "volume is not attached" }` |

**BlockVolumeView schema:**

```json
{
  "id":                   "string (UUID)",
  "name":                 "string",
  "sizeGiB":              "number",
  "state":                "available | attached | deleting",
  "attachedToInstanceId": "string (empty when not attached)",
  "createdAt":            "ISO-8601 timestamp"
}
```

---

## Sv1 – Service Orientation (Architecture Overview)

```
┌──────────────────────────────────────────────────────────────────────┐
│                     uim-block-storage-service                        │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Infrastructure Layer  (Adapters)                               │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────┐   ┌──────────────────────────────┐│ │
│  │  │  BlockStorageController │   │  InMemoryBlockVolumeRepository││ │
│  │  │  (HTTP / vibe.d adapter)│   │  (Persistence adapter)       ││ │
│  │  └──────────┬──────────────┘   └──────────────┬───────────────┘│ │
│  └─────────────┼────────────────────────────────  │  ──────────────┘ │
│                │                                  │                  │
│  ┌─────────────▼──────────────────────────────────▼──────────────┐  │
│  │  Application Layer  (Use Cases)                                │  │
│  │                                                                │  │
│  │  CreateVolume  DeleteVolume  AttachVolume                      │  │
│  │  DetachVolume  ListVolumes   GetVolume                         │  │
│  └─────────────────────────────┬──────────────────────────────────┘  │
│                                │                                     │
│  ┌─────────────────────────────▼──────────────────────────────────┐  │
│  │  Domain Layer  (Core Business Rules – no framework deps)       │  │
│  │                                                                │  │
│  │  BlockVolume  ·  VolumeState  ·  IBlockVolumeRepository        │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
         ▲                                          ▲
  REST / JSON                               PID file (pidman)
  (HTTP clients,                            /var/run/uim-block-
   Kubernetes probes)                       storage-service.pid
```

### Dependency Rule

All arrows point **inward** toward the Domain layer; the Domain knows nothing about vibe.d, HTTP, or the persistence technology. This guarantees the core logic can be tested without any framework or I/O dependencies.
