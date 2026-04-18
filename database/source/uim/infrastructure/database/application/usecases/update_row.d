module uim.infrastructure.database.application.usecases.update_row;

import uim.infrastructure.database.application.dto.commands : UpdateRowCommand;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class UpdateRowUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    bool execute(in UpdateRowCommand command) {
        enforceCommand(command);
        return repository.update(command.schema, command.table, command.id, command.data);
    }

    private void enforceCommand(in UpdateRowCommand command) {
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
