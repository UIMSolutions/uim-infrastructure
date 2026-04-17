module uim.infrastructure.mongo.domain.entities.document;

import vibe.data.json : Json;

/// Domain entity representing a MongoDB document.
struct MongoDocument {
    string id;
    string database;
    string collection;
    Json data;

    /// Returns the fully-qualified namespace (db.collection).
    string namespace() const {
        return database ~ "." ~ collection;
    }
}

unittest {
    auto doc = MongoDocument("abc123", "mydb", "users", Json.emptyObject);
    assert(doc.namespace() == "mydb.users");
    assert(doc.id == "abc123");
}
