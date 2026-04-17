module uim.infrastructure.mongo.infrastructure.persistence.mongodb.mongo_repository;

import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;
import std.conv : to;
import std.uuid : randomUUID;
import vibe.data.bson : Bson;
import vibe.data.json : Json;
import vibe.db.mongo.client : MongoClient;
import vibe.db.mongo.collection : MongoCollection;

/// MongoDB adapter implementing the repository port via vibe.d's MongoClient.
class VibeMongoRepository : IMongoRepository {
    private MongoClient client;

    this(string connectionString) {
        import vibe.db.mongo.mongo : connectMongoDB;
        this.client = connectMongoDB(connectionString);
    }

    override string insert(string database, string collection, Json data) {
        auto id = randomUUID().to!string;
        data["_id"] = id;
        auto bsonData = Bson(data);
        getCollection(database, collection).insertOne(bsonData);
        return id;
    }

    override MongoDocument findById(string database, string collection, string id) {
        auto coll = getCollection(database, collection);
        auto filter = Bson.emptyObject;
        filter["_id"] = Bson(id);
        auto result = coll.findOne(filter);
        if (result.isNull) {
            return MongoDocument.init;
        }
        return bsonToDocument(database, collection, result);
    }

    override MongoDocument[] find(string database, string collection, Json filter) {
        auto coll = getCollection(database, collection);
        Bson queryFilter;
        if (filter.type == Json.Type.undefined || filter.type == Json.Type.null_) {
            queryFilter = Bson.emptyObject;
        } else {
            queryFilter = Bson(filter);
        }
        MongoDocument[] results;
        foreach (doc; coll.find(queryFilter)) {
            results ~= bsonToDocument(database, collection, doc);
        }
        return results;
    }

    override MongoDocument[] list(string database, string collection) {
        return find(database, collection, Json.emptyObject);
    }

    override bool update(string database, string collection, string id, Json data) {
        auto coll = getCollection(database, collection);
        auto filter = Bson.emptyObject;
        filter["_id"] = Bson(id);
        auto bsonData = Bson(data);
        auto result = coll.replaceOne(filter, bsonData);
        return result.modifiedCount > 0;
    }

    override bool remove(string database, string collection, string id) {
        auto coll = getCollection(database, collection);
        auto filter = Bson.emptyObject;
        filter["_id"] = Bson(id);
        auto result = coll.deleteOne(filter);
        return result.deletedCount > 0;
    }

    private MongoCollection getCollection(string database, string collection) {
        return client.getCollection(database ~ "." ~ collection);
    }

    private MongoDocument bsonToDocument(string database, string collection, Bson raw) {
        string id;
        auto idField = raw.tryIndex("_id");
        if (!idField.isNull) {
            id = idField.get.to!string;
        }
        auto jsonData = raw.toJson();
        return MongoDocument(id, database, collection, jsonData);
    }
}
