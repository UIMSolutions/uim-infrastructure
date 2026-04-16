# UML Diagrams – uim-block-storage-service

## 1. Class Diagram

```plantuml
@startuml block-storage-class-diagram
skinparam classAttributeIconSize 0
skinparam packageStyle rectangle

package "domain" {
  enum VolumeState {
    available
    attached
    deleting
  }

  class BlockVolume {
    + id : string
    + name : string
    + sizeGiB : ulong
    + state : VolumeState
    + attachedToInstanceId : string
    + createdAt : SysTime
  }

  interface IBlockVolumeRepository {
    + save(volume : BlockVolume) : void
    + remove(id : string) : void
    + list() : BlockVolume[]
    + findById(id : string) : BlockVolume*
  }

  BlockVolume ..> VolumeState
}

package "application.dto" {
  class CreateVolumeCommand {
    + name : string
    + sizeGiB : ulong
  }
  class DeleteVolumeCommand {
    + id : string
  }
  class AttachVolumeCommand {
    + id : string
    + instanceId : string
  }
  class DetachVolumeCommand {
    + id : string
  }
  class GetVolumeQuery {
    + id : string
  }
}

package "application.usecases" {
  class CreateVolumeUseCase {
    - repository : IBlockVolumeRepository
    + execute(cmd : CreateVolumeCommand) : BlockVolume
  }
  class DeleteVolumeUseCase {
    - repository : IBlockVolumeRepository
    + execute(cmd : DeleteVolumeCommand) : void
  }
  class AttachVolumeUseCase {
    - repository : IBlockVolumeRepository
    + execute(cmd : AttachVolumeCommand) : BlockVolume
  }
  class DetachVolumeUseCase {
    - repository : IBlockVolumeRepository
    + execute(cmd : DetachVolumeCommand) : BlockVolume
  }
  class ListVolumesUseCase {
    - repository : IBlockVolumeRepository
    + execute() : BlockVolume[]
  }
  class GetVolumeUseCase {
    - repository : IBlockVolumeRepository
    + execute(q : GetVolumeQuery) : BlockVolume*
  }

  CreateVolumeUseCase --> IBlockVolumeRepository
  DeleteVolumeUseCase --> IBlockVolumeRepository
  AttachVolumeUseCase --> IBlockVolumeRepository
  DetachVolumeUseCase --> IBlockVolumeRepository
  ListVolumesUseCase  --> IBlockVolumeRepository
  GetVolumeUseCase    --> IBlockVolumeRepository

  CreateVolumeUseCase ..> CreateVolumeCommand
  DeleteVolumeUseCase ..> DeleteVolumeCommand
  AttachVolumeUseCase ..> AttachVolumeCommand
  DetachVolumeUseCase ..> DetachVolumeCommand
  GetVolumeUseCase    ..> GetVolumeQuery
}

package "infrastructure.persistence.memory" {
  class InMemoryBlockVolumeRepository {
    - volumes : BlockVolume[]
    - mutex : Mutex
    + save(volume : BlockVolume) : void
    + remove(id : string) : void
    + list() : BlockVolume[]
    + findById(id : string) : BlockVolume*
  }
  InMemoryBlockVolumeRepository ..|> IBlockVolumeRepository
}

package "infrastructure.http.controllers" {
  class BlockVolumeView {
    + id : string
    + name : string
    + sizeGiB : ulong
    + state : string
    + attachedToInstanceId : string
    + createdAt : string
  }

  class BlockStorageController {
    - createUseCase : CreateVolumeUseCase
    - deleteUseCase : DeleteVolumeUseCase
    - attachUseCase : AttachVolumeUseCase
    - detachUseCase : DetachVolumeUseCase
    - listUseCase : ListVolumesUseCase
    - getUseCase : GetVolumeUseCase
    + registerRoutes(router : URLRouter) : void
    + health(req, res) : void
    + listVolumes(req, res) : void
    + createVolume(req, res) : void
    + getVolume(req, res) : void
    + deleteVolume(req, res) : void
    + attachVolume(req, res) : void
    + detachVolume(req, res) : void
  }

  BlockStorageController --> CreateVolumeUseCase
  BlockStorageController --> DeleteVolumeUseCase
  BlockStorageController --> AttachVolumeUseCase
  BlockStorageController --> DetachVolumeUseCase
  BlockStorageController --> ListVolumesUseCase
  BlockStorageController --> GetVolumeUseCase
  BlockStorageController ..> BlockVolumeView
}
@enduml
```

---

## 2. Sequence Diagram – Create Volume

```plantuml
@startuml create-volume-sequence
actor Client
participant BlockStorageController
participant CreateVolumeUseCase
participant InMemoryBlockVolumeRepository

Client -> BlockStorageController : POST /v1/volumes\n{ name, sizeGiB }
BlockStorageController -> CreateVolumeUseCase : execute(CreateVolumeCommand)
CreateVolumeUseCase -> CreateVolumeUseCase : validate name & sizeGiB
CreateVolumeUseCase -> InMemoryBlockVolumeRepository : save(BlockVolume)
InMemoryBlockVolumeRepository --> CreateVolumeUseCase : ok
CreateVolumeUseCase --> BlockStorageController : BlockVolume
BlockStorageController --> Client : 201 Created\n{ id, name, sizeGiB, state: "available", ... }
@enduml
```

---

## 3. Sequence Diagram – Attach Volume

```plantuml
@startuml attach-volume-sequence
actor Client
participant BlockStorageController
participant AttachVolumeUseCase
participant InMemoryBlockVolumeRepository

Client -> BlockStorageController : POST /v1/volumes/<id>/attach\n{ instanceId }
BlockStorageController -> AttachVolumeUseCase : execute(AttachVolumeCommand)
AttachVolumeUseCase -> InMemoryBlockVolumeRepository : findById(id)
InMemoryBlockVolumeRepository --> AttachVolumeUseCase : BlockVolume (available)
AttachVolumeUseCase -> AttachVolumeUseCase : set state=attached, attachedToInstanceId
AttachVolumeUseCase -> InMemoryBlockVolumeRepository : save(updated volume)
InMemoryBlockVolumeRepository --> AttachVolumeUseCase : ok
AttachVolumeUseCase --> BlockStorageController : BlockVolume
BlockStorageController --> Client : 200 OK\n{ ..., state: "attached", attachedToInstanceId }
@enduml
```

---

## 4. Sequence Diagram – Delete Volume

```plantuml
@startuml delete-volume-sequence
actor Client
participant BlockStorageController
participant DeleteVolumeUseCase
participant InMemoryBlockVolumeRepository

Client -> BlockStorageController : DELETE /v1/volumes/<id>
BlockStorageController -> DeleteVolumeUseCase : execute(DeleteVolumeCommand)
DeleteVolumeUseCase -> InMemoryBlockVolumeRepository : findById(id)
InMemoryBlockVolumeRepository --> DeleteVolumeUseCase : BlockVolume
alt state == attached
  DeleteVolumeUseCase --> BlockStorageController : Exception("cannot delete attached volume")
  BlockStorageController --> Client : 400 Bad Request
else state == available or deleting
  DeleteVolumeUseCase -> InMemoryBlockVolumeRepository : remove(id)
  InMemoryBlockVolumeRepository --> DeleteVolumeUseCase : ok
  DeleteVolumeUseCase --> BlockStorageController : void
  BlockStorageController --> Client : 204 No Content
end
@enduml
```

---

## 5. Component Diagram

```plantuml
@startuml block-storage-component
skinparam componentStyle rectangle

package "uim-block-storage-service" {
  [app.d\n(entry point)] --> [BlockStorageController]
  [app.d\n(entry point)] --> [InMemoryBlockVolumeRepository]

  package "infrastructure" {
    [BlockStorageController]
    [InMemoryBlockVolumeRepository]
  }

  package "application" {
    [CreateVolumeUseCase]
    [DeleteVolumeUseCase]
    [AttachVolumeUseCase]
    [DetachVolumeUseCase]
    [ListVolumesUseCase]
    [GetVolumeUseCase]
  }

  package "domain" {
    [BlockVolume]
    [IBlockVolumeRepository]
  }

  [BlockStorageController] --> [CreateVolumeUseCase]
  [BlockStorageController] --> [DeleteVolumeUseCase]
  [BlockStorageController] --> [AttachVolumeUseCase]
  [BlockStorageController] --> [DetachVolumeUseCase]
  [BlockStorageController] --> [ListVolumesUseCase]
  [BlockStorageController] --> [GetVolumeUseCase]

  [CreateVolumeUseCase] --> [IBlockVolumeRepository]
  [DeleteVolumeUseCase] --> [IBlockVolumeRepository]
  [AttachVolumeUseCase] --> [IBlockVolumeRepository]
  [DetachVolumeUseCase] --> [IBlockVolumeRepository]
  [ListVolumesUseCase]  --> [IBlockVolumeRepository]
  [GetVolumeUseCase]    --> [IBlockVolumeRepository]

  [InMemoryBlockVolumeRepository] ..|> [IBlockVolumeRepository]
}

[HTTP Client] --> [BlockStorageController] : REST / JSON
@enduml
```

---

## 6. State Diagram – Volume Lifecycle

```plantuml
@startuml volume-state
[*] --> available : CREATE

available --> attached  : ATTACH
attached  --> available : DETACH
available --> [*]        : DELETE
@enduml
```
