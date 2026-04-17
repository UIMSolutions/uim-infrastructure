module uim.infrastructure.mongo.infrastructure.persistence.memory.mongo_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;
import std.conv : to;
import std.uuid : randomUUID;
import vibe.data.json : Json;

/// In-memory implementation of IMongoRepository for testing and local development.
class InMemoryMongoRepository : IMongoRepository {
    /// Keyed by "database.collection", each entry is an AA of id -> document.
    private MongoDocument[][string] collections;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override string insert(string database, string collection, Json data) {
        synchronized (mutex) {
            auto id = randomUUID().to!string;
            auto ns = database ~ "." ~ collection;
            auto doc = MongoDocument(id, database, collection, data);
            collections[ns] ~= doc;
            return id;
        }
    }

    override MongoDocument findById(string database, string collection, string id) {
        synchronized (mutex) {
            auto ns = database ~ "." ~ collection;
            if (auto docs = ns in collections) {
                foreach (doc; *docs) {
                    if (doc.id == id) {
                        return doc;
                    }
                }
            }
            return MongoDocument.init;
        }
    }

    override MongoDocument[] find(string database, string collection, Json filter) {
        synchronized (mutex) {
            auto ns = database ~ "." ~ collection;
            if (auto docs = ns in collections) {
                if (filter.type == Json.Type.undefined || filter.type == Json.Type.null_) {
                    return (*docs).dup;
                }
                MongoDocument[] result;
                foreach (doc; *docs) {
                    if (matchesFilter(doc.data, filter)) {
                        result ~= doc;
                    }
                }
                return result;
            }
            return [];
        }
    }

    override MongoDocument[] list(string database, string collection) {
        synchronized (mutex) {
            auto ns = database ~ "." ~ collection;
            if (auto docs = ns in collections) {
                return (*docs).dup;
            }
            return [];
        }
    }

    override bool update(string database, string collection, string id, Json data) {
        synchronized (mutex) {
            auto ns = database ~ "." ~ collection;
            if (auto docs = ns in collections) {
                foreach (ref doc; *docs) {
                    if (doc.id == id) {
                        doc.data = data;
                        return true;
                    }
                }
            }
            return false;
        }
    }

    override bool remove(string database, string collection, string id) {
        synchronized (mutex) {
            auto ns = database ~ "." ~ collection;
            if (auto docs = ns in collections) {
                MongoDocument[] remaining;
                bool found = false;
                foreach (doc; *docs) {
                    if (doc.id == id) {
                        found = true;
                    } else {
                        remaining ~= doc;
                    }
                }
                if (found) {
                    collections[ns] = remaining;
                }
                return found;
            }
            return false;
        }
    }

    /// Simple filter matcher: checks that all top-level keys in filter exist
    /// in data with the same value.
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
    auto repo = new InMemoryMongoRepository();

    auto data = Json.emptyObject;
    data["name"] = "Alice";
    data["age"] = 30;

    auto id = repo.insert("testdb", "users", data);
    assert(id.length > 0);

    auto doc = repo.findById("testdb", "users", id);
    assert(doc.id == id);
    assert(doc.data["name"].get!string == "Alice");

    auto all = repo.list("testdb", "users");
    assert(all.length == 1);

    auto updatedData = Json.emptyObject;
    updatedData["name"] = "Alice";
    updatedData["age"] = 31;
    assert(repo.update("testdb", "users", id, updatedData));

    auto filter = Json.emptyObject;
    filter["name"] = "Alice";
    auto found = repo.find("testdb", "users", filter);
    assert(found.length == 1);
    assert(found[0].data["age"].get!int == 31);

    assert(repo.remove("testdb", "users", id));
    assert(repo.list("testdb", "users").length == 0);
}
