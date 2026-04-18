module uim.infrastructure.database.application.dto.commands;

import vibe.data.json : Json;

/// Command to insert a new row into a table.
struct InsertRowCommand {
    string schema;
    string table;
    Json data;
}

/// Command to update an existing row by id.
struct UpdateRowCommand {
    string schema;
    string table;
    string id;
    Json data;
}

/// Command to delete a row by id.
struct DeleteRowCommand {
    string schema;
    string table;
    string id;
}

/// Query to retrieve a single row by id.
struct FindRowQuery {
    string schema;
    string table;
    string id;
}

/// Query to retrieve rows matching a filter.
struct FindRowsQuery {
    string schema;
    string table;
    Json filter;
}

/// Query to list all rows in a table.
struct ListRowsQuery {
    string schema;
    string table;
}
