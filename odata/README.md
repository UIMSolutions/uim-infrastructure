# UIM OData Service

Cloud-native OData V4 service inspired by [SAP OData Library](https://github.com/SAP/odata-library), built with **vibe.d** and **D** using a combination of clean and hexagonal architecture.

## Overview

This service provides a REST API implementing OData V4 protocol concepts:

- **Entity Types** - Structured type definitions with typed properties, keys, and navigation properties
- **Entity Sets** - Named collections of entities (like database tables)
- **Entities** - Data instances conforming to an EntityType, with full CRUD support
- **Properties** - Typed fields (Edm.String, Edm.Int32, Edm.Boolean, Edm.Double, etc.)
- **Navigation Properties** - Relationships between entity types (one-to-one, one-to-many)
- **Query Options** - OData system query options: $filter, $orderby, $top, $skip, $count, $select, $expand, $search
- **Functions and Actions** - Custom operations (read-only functions, side-effect actions)
- **Service Document** - Root document listing available EntitySets and operations

## Architecture

```
Clean + Hexagonal Architecture

Domain Layer (entities + port interfaces)
    |
Application Layer (use cases + DTOs)
    |
Infrastructure Layer
    +-- Inbound:  HTTP Controller (vibe.d REST API with OData URL conventions)
    +-- Outbound: In-Memory Repositories (thread-safe with Mutex)
    |
Composition Root (app.d wires everything)
```

## API Endpoints

### Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |

### Service Document
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/odata/` | OData service document |

### Metadata - Entity Types
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/odata/$metadata/entity-types` | Define an EntityType |
| GET | `/odata/$metadata/entity-types` | List all EntityTypes |
| DELETE | `/odata/$metadata/entity-types/{name}` | Delete an EntityType |

### Metadata - Entity Sets
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/odata/$metadata/entity-sets` | Create an EntitySet |
| GET | `/odata/$metadata/entity-sets` | List all EntitySets |
| DELETE | `/odata/$metadata/entity-sets/{name}` | Delete an EntitySet |

### Metadata - Functions/Actions
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/odata/$metadata/function-imports` | Register a Function/Action |
| GET | `/odata/$metadata/function-imports` | List all Functions/Actions |

### Entity CRUD (OData URL Conventions)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/odata/{EntitySet}` | Create an entity |
| GET | `/odata/{EntitySet}` | Query entity collection (with $filter, $orderby, $top, $skip, $count, $search) |
| GET | `/odata/{EntitySet}('{id}')` | Get individual entity by ID |
| PATCH | `/odata/{EntitySet}('{id}')` | Update entity (merge semantics) |
| DELETE | `/odata/{EntitySet}('{id}')` | Delete entity |

## Example Usage

### 1. Define an EntityType
```bash
curl -X POST http://localhost:8080/odata/\$metadata/entity-types \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Person",
    "namespace": "TripPin",
    "keyProperties": ["UserName"],
    "properties": [
      {"name": "UserName", "type": "Edm.String", "nullable": false},
      {"name": "FirstName", "type": "Edm.String"},
      {"name": "LastName", "type": "Edm.String"},
      {"name": "Email", "type": "Edm.String"},
      {"name": "Gender", "type": "Edm.String"}
    ],
    "navigationProperties": [
      {"name": "Friends", "targetEntityType": "Person", "multiplicity": "many"}
    ]
  }'
```

### 2. Create an EntitySet
```bash
curl -X POST http://localhost:8080/odata/\$metadata/entity-sets \
  -H "Content-Type: application/json" \
  -d '{"name": "People", "entityTypeName": "Person"}'
```

### 3. Create Entities
```bash
curl -X POST http://localhost:8080/odata/People \
  -H "Content-Type: application/json" \
  -d '{"UserName": "russellwhyte", "FirstName": "Russell", "LastName": "Whyte", "Gender": "Male"}'

curl -X POST http://localhost:8080/odata/People \
  -H "Content-Type: application/json" \
  -d '{"UserName": "scottketchum", "FirstName": "Scott", "LastName": "Ketchum", "Gender": "Male"}'
```

### 4. Query with OData Options
```bash
# Get all people
curl "http://localhost:8080/odata/People"

# Filter by FirstName
curl "http://localhost:8080/odata/People?\$filter=FirstName%20eq%20'Scott'"

# Order by LastName descending, top 5
curl "http://localhost:8080/odata/People?\$orderby=LastName%20desc&\$top=5"

# Pagination
curl "http://localhost:8080/odata/People?\$top=10&\$skip=20"

# Count
curl "http://localhost:8080/odata/People?\$count=true"

# Search
curl "http://localhost:8080/odata/People?\$search=Boise"
```

### 5. Get Individual Entity
```bash
curl "http://localhost:8080/odata/People('russellwhyte')"
```

### 6. Update Entity (PATCH)
```bash
curl -X PATCH "http://localhost:8080/odata/People('russellwhyte')" \
  -H "Content-Type: application/json" \
  -d '{"Email": "russell@example.com"}'
```

### 7. Delete Entity
```bash
curl -X DELETE "http://localhost:8080/odata/People('scottketchum')"
```

### 8. Service Document
```bash
curl "http://localhost:8080/odata/"
```

## Build and Run

### Local
```bash
cd odata
dub build
./uim-odata-service
```

### Docker
```bash
docker build -t uim-odata-service .
docker run -p 8080:8080 uim-odata-service
```

### Podman
```bash
podman build -t uim-odata-service -f Containerfile .
podman run -p 8080:8080 uim-odata-service
```

### Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Project Structure

```
odata/
  dub.sdl
  Dockerfile
  Containerfile
  README.md
  k8s/
    namespace.yaml
    configmap.yaml
    deployment.yaml
    service.yaml
  source/
    app.d                              # Composition root
    uim/infrastructure/odata/
      domain/
        entities/
          property.d                   # Property with EdmType enum
          navigation_property.d        # NavigationProperty with Multiplicity
          entity_type.d                # EntityType (schema definition)
          entity_set.d                 # EntitySet (named collection)
          entity.d                     # Entity (data instance)
          service_document.d           # Service document with endpoints
          function_import.d            # Functions and Actions
          query_options.d              # OData query options ($filter, $orderby, etc.)
        ports/
          repositories/
            entity_type.d              # IEntityTypeRepository
            entity_set.d               # IEntitySetRepository
            entity.d                   # IEntityRepository (with query support)
            function_import.d          # IFunctionImportRepository
      application/
        dtos/
          entity_type.d                # EntityType DTOs
          entity_set.d                 # EntitySet DTOs
          entity.d                     # Entity + EntityCollection DTOs
          function_import.d            # Function/Action DTOs
          service_document.d           # Service document DTOs
        usecases/
          create_entity_type.d
          list_entity_types.d
          delete_entity_type.d
          create_entity_set.d
          list_entity_sets.d
          delete_entity_set.d
          create_entity.d
          get_entity.d
          query_entities.d             # Query with $filter/$orderby/$top/$skip/$count/$search
          update_entity.d              # PATCH merge semantics
          delete_entity.d
          get_service_document.d
          create_function_import.d
          list_function_imports.d
      infrastructure/
        adapters/
          http/
            controller.d               # OData URL convention routes
          inmemory/
            entity_type_repository.d
            entity_set_repository.d
            entity_repository.d        # With $filter, $orderby, $search, $top, $skip support
            function_import_repository.d
```

## OData V4 Concepts Modeled

- **Entity Data Model (EDM)**: EntityTypes define schemas with typed properties and keys
- **EntitySets**: Named collections mapped to EntityTypes
- **OData URL conventions**: `EntitySet('{key}')` for individual entities
- **System query options**: $filter (eq), $orderby (asc/desc), $top, $skip, $count, $search
- **CRUD operations**: POST (create), GET (read), PATCH (update with merge), DELETE
- **Service document**: Root endpoint listing all available EntitySets and operations
- **Functions/Actions**: Custom operations registered via metadata
- **OData JSON format**: @odata.context, @odata.id, @odata.editLink, @odata.count annotations

## License

Apache-2.0
