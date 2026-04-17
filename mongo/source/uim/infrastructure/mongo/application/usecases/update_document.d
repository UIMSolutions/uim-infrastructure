module uim.infrastructure.mongo.application.usecases.update_document;

import uim.infrastructure.mongo.application.dto.commands : UpdateDocumentCommand;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;

class UpdateDocumentUseCase {
    private IMongoRepository repository;

    this(IMongoRepository repository) {
        this.repository = repository;
    }

    bool execute(in UpdateDocumentCommand command) {
        enforceCommand(command);
        return repository.update(command.database, command.collection, command.id, command.data);
    }

    private void enforceCommand(in UpdateDocumentCommand command) {
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
