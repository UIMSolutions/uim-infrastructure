module uim.infrastructure.mongo.application.usecases.find_documents;

import uim.infrastructure.mongo.application.dto.commands : FindDocumentsQuery;
import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;
import vibe.data.json : Json;

class FindDocumentsUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    MongoDocument[] execute(in FindDocumentsQuery query) {
        if (query.database.length == 0) {
            throw new Exception("database must not be empty");
        }
        if (query.collection.length == 0) {
            throw new Exception("collection must not be empty");
        }

        return repository.find(query.database, query.collection, query.filter);
    }
}
