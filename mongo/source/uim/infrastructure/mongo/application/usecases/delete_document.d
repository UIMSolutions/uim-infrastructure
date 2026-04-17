module uim.infrastructure.mongo.application.usecases.delete_document;

import uim.infrastructure.mongo.application.dto.commands : DeleteDocumentCommand;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;

class DeleteDocumentUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    bool execute(in DeleteDocumentCommand command) {
        enforceCommand(command);
        return repository.remove(command.database, command.collection, command.id);
    }

    private void enforceCommand(in DeleteDocumentCommand command) {
        if (command.database.length == 0) {
            throw new Exception("database must not be empty");
        }
        if (command.collection.length == 0) {
            throw new Exception("collection must not be empty");
        }
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
    }
}
