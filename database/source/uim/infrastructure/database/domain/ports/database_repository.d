module uim.infrastructure.database.domain.ports.database_repository;

import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import vibe.data.json : Json;

/// Port interface for relational database persistence.
/// Infrastructure adapters (in-memory, PostgreSQL, MySQL, …) implement this contract.
interface IDatabaseRepository {
    /// Insert a row into schema.table. Returns the assigned id.
    string insert(string schema, string table, Json data);

    /// Find a single row by id. Returns DatabaseRow.init if not found.
    DatabaseRow findById(string schema, string table, string id);

    /// Find rows whose top-level columns match all key/value pairs in filter.
    DatabaseRow[] find(string schema, string table, Json filter);

    /// List all rows in schema.table.
    DatabaseRow[] list(string schema, string table);

    /// Update a row by id with the supplied data. Returns true on success.
    bool update(string schema, string table, string id, Json data);

    /// Delete a row by id. Returns true on success.
    bool remove(string schema, string table, string id);
}
