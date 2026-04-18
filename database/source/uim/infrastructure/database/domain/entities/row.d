module uim.infrastructure.database.domain.entities.row;

import vibe.data.json : Json;

/// Domain entity representing a single row in a relational table.
struct DatabaseRow {
    /// Unique identifier assigned on insert.
    string id;
    /// The schema (or logical database namespace) the table belongs to.
    string schema;
    /// The table the row belongs to.
    string table;
    /// Row data serialised as a JSON object (column → value).
    Json data;

    /// Returns the fully-qualified table reference (schema.table).
    string qualifiedTable() const {
        return schema ~ "." ~ table;
    }
}

unittest {
    auto row = DatabaseRow("r1", "public", "users", Json.emptyObject);
    assert(row.qualifiedTable() == "public.users");
    assert(row.id == "r1");
}
