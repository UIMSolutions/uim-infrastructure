# uim-database-service

A generic relational-database microservice built with **D** and **vibe.d**, following a combined **Clean Architecture** and **Hexagonal (Ports & Adapters) Architecture**.

---

## Architecture

```
database/
└── source/
    ├── app.d                                   # Entry point – wires adapters to use-cases
    └── uim/infrastructure/database/
        │
        ├── domain/                             # ① Core domain (no framework dependencies)
        │   ├── entities/row.d                  #   DatabaseRow entity
        │   └── ports/database_repository.d     #   IDatabaseRepository port (hexagonal boundary)
        │
        ├── application/                        # ② Application / use-case layer
        │   ├── dto/commands.d                  #   Commands & query DTOs
        │   └── usecases/
        │       ├── insert_row.d
        │       ├── find_row.d
        │       ├── find_rows.d
        │       ├── list_rows.d
        │       ├── update_row.d
        │       └── delete_row.d
        │
        └── infrastructure/                     # ③ Infrastructure / adapter layer
            ├── persistence/
            │   └── memory/database_repository.d  # In-memory adapter (tests & local dev)
            └── http/
                └── controllers/database.d        # vibe.d HTTP controller (primary adapter)
```

### Layer responsibilities

| Layer | Role |
|---|---|
| **Domain** | Pure D structs and interfaces — zero framework dependencies. |
| **Application** | Orchestrates domain objects via use-cases; uses DTOs for I/O. |
| **Infrastructure** | Adapts external systems (HTTP, databases) to the domain's ports. |

---

## HTTP API

All endpoints return `application/json`.

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Liveness probe |
| `GET` | `/v1/rows/<schema>/<table>` | List all rows |
| `GET` | `/v1/rows/<schema>/<table>/<id>` | Find row by id |
| `POST` | `/v1/rows/<schema>/<table>` | Insert a row (body: JSON object) |
| `POST` | `/v1/rows/<schema>/<table>/filter` | Find rows matching a filter (body: JSON object) |
| `PUT` | `/v1/rows/<schema>/<table>/<id>` | Update a row (body: JSON object) |
| `DELETE` | `/v1/rows/<schema>/<table>/<id>` | Delete a row |

---

## Configuration (environment variables)

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | HTTP listen port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `DATABASE_URL` | _(none)_ | Connection URL for a live SQL adapter (in-memory adapter used when absent) |

---

## Build & run

```bash
# inside database/
dub build
./uim-database-service
```

---

## Extending with a real SQL adapter

1. Create `source/uim/infrastructure/database/infrastructure/persistence/postgres/database_repository.d`.
2. Implement `IDatabaseRepository` using a PostgreSQL client (e.g. `dpq2` or `vibe-d:db`).
3. In `app.d`, detect `DATABASE_URL` and return the new adapter from `createRepository()`.
