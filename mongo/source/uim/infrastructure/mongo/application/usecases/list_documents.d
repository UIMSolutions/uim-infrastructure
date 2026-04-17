module uim.infrastructure.mongo.application.usecases.list_documents;

import uim.infrastructure.mongo.application.dto.commands : ListDocumentsQuery;
import uim.infrastructure.mongo.domain.entities.document : MongoDocument;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;

class ListDocumentsUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    MongoDocument[] execute(in ListDocumentsQuery query) {
        if (query.database.length == 0) {
            throw new Exception("database must not be empty");
        }
        if (query.collection.length == 0) {
            throw new Exception("collection must not be empty");
        }

        return repository.list(query.database, query.collection);
    }
}
