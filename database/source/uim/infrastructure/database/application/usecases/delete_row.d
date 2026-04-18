module uim.infrastructure.database.application.usecases.delete_row;

import uim.infrastructure.database.application.dto.commands : DeleteRowCommand;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class DeleteRowUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    bool execute(in DeleteRowCommand command) {
        enforceCommand(command);
        return repository.remove(command.schema, command.table, command.id);
    }

    private void enforceCommand(in DeleteRowCommand command) {
        if (command.schema.length == 0) {
            throw new Exception("schema must not be empty");
        }
        if (command.table.length == 0) {
            throw new Exception("table must not be empty");
        }
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
    }
}
