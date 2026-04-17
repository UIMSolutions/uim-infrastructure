module uim.infrastructure.mongo.domain.ports.mongo_repository;

import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import vibe.data.json : Json;

/// Port interface for MongoDB persistence.
/// Infrastructure adapters implement this contract.
interface IMongoRepository {
    /// Insert a document. Returns the assigned id.
    string insert(string database, string collection, Json data);

    /// Find a single document by id. Returns null Json if not found.
    MongoDocument findById(string database, string collection, string id);

    /// Find documents matching a filter.
    MongoDocument[] find(string database, string collection, Json filter);

    /// List all documents in a collection.
    MongoDocument[] list(string database, string collection);

    /// Update a document by id. Returns true on success.
    bool update(string database, string collection, string id, Json data);

    /// Delete a document by id. Returns true on success.
    bool remove(string database, string collection, string id);
}
