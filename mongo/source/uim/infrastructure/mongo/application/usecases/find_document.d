module uim.infrastructure.mongo.application.usecases.find_document;

import uim.infrastructure.mongo.application.dto.commands : FindDocumentQuery;
import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;

class FindDocumentUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    MongoDocument execute(in FindDocumentQuery query) {
        if (query.database.length == 0) {
            throw new Exception("database must not be empty");
        }
        if (query.collection.length == 0) {
            throw new Exception("collection must not be empty");
        }
        if (query.id.length == 0) {
            throw new Exception("id must not be empty");
        }

        return repository.findById(query.database, query.collection, query.id);
    }
}
