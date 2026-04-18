module uim.infrastructure.database.infrastructure.persistence.memory.database_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;
import std.conv : to;
import std.uuid : randomUUID;
import vibe.data.json : Json;

/// In-memory implementation of IDatabaseRepository for testing and local development.
class InMemoryDatabaseRepository : IDatabaseRepository {
    /// Rows keyed by "schema.table"; each entry is an array of DatabaseRow.
    private DatabaseRow[][string] tables;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override string insert(string schema, string table, Json data) {
        synchronized (mutex) {
            auto id = randomUUID().to!string;
            auto key = schema ~ "." ~ table;
            auto row = DatabaseRow(id, schema, table, data);
            tables[key] ~= row;
            return id;
        }
    }

    override DatabaseRow findById(string schema, string table, string id) {
        synchronized (mutex) {
            auto key = schema ~ "." ~ table;
            if (auto rows = key in tables) {
                foreach (row; *rows) {
                    if (row.id == id) {
                        return row;
                    }
                }
            }
            return DatabaseRow.init;
        }
    }

    override DatabaseRow[] find(string schema, string table, Json filter) {
        synchronized (mutex) {
            auto key = schema ~ "." ~ table;
            if (auto rows = key in tables) {
                if (filter.type == Json.Type.undefined || filter.type == Json.Type.null_) {
                    return (*rows).dup;
                }
                DatabaseRow[] result;
                foreach (row; *rows) {
                    if (matchesFilter(row.data, filter)) {
                        result ~= row;
                    }
                }
                return result;
            }
            return [];
        }
    }

    override DatabaseRow[] list(string schema, string table) {
        synchronized (mutex) {
            auto key = schema ~ "." ~ table;
            if (auto rows = key in tables) {
                return (*rows).dup;
            }
            return [];
        }
    }

    override bool update(string schema, string table, string id, Json data) {
        synchronized (mutex) {
            auto key = schema ~ "." ~ table;
            if (auto rows = key in tables) {
                foreach (ref row; *rows) {
                    if (row.id == id) {
                        row.data = data;
                        return true;
                    }
                }
            }
            return false;
        }
    }

    override bool remove(string schema, string table, string id) {
        synchronized (mutex) {
            auto key = schema ~ "." ~ table;
            if (auto rows = key in tables) {
                DatabaseRow[] remaining;
                bool found = false;
                foreach (row; *rows) {
                    if (row.id == id) {
                        found = true;
                    } else {
                        remaining ~= row;
                    }
                }
                if (found) {
                    tables[key] = remaining;
                }
                return found;
            }
            return false;
        }
    }

    /// Strict equality filter: every top-level key present in `filter` must exist
    /// in `data` with an identical value (no type coercion, no partial matching).
    /// Returns false when either argument is not a JSON object.
    private bool matchesFilter(Json data, Json filter) {
        if (data.type != Json.Type.object || filter.type != Json.Type.object) {
            return false;
        }
        foreach (string key, value; filter) {
            auto field = key in data;
            if (field is null || *field != value) {
                return false;
            }
        }
        return true;
    }
}

unittest {
    auto repo = new InMemoryDatabaseRepository();

    auto data = Json.emptyObject;
    data["name"] = "Alice";
    data["age"] = 30;

    auto id = repo.insert("public", "users", data);
    assert(id.length > 0);

    auto row = repo.findById("public", "users", id);
    assert(row.id == id);
    assert(row.data["name"].get!string == "Alice");

    auto all = repo.list("public", "users");
    assert(all.length == 1);

    auto updated = Json.emptyObject;
    updated["name"] = "Alice";
    updated["age"] = 31;
    assert(repo.update("public", "users", id, updated));

    auto filter = Json.emptyObject;
    filter["name"] = "Alice";
    auto found = repo.find("public", "users", filter);
    assert(found.length == 1);
    assert(found[0].data["age"].get!int == 31);

    assert(repo.remove("public", "users", id));
    assert(repo.list("public", "users").length == 0);
}
