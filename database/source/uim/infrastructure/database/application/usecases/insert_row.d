module uim.infrastructure.database.application.usecases.insert_row;

import uim.infrastructure.database.application.dto.commands : InsertRowCommand;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class InsertRowUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    string execute(in InsertRowCommand command) {
        enforceCommand(command);
        return repository.insert(command.schema, command.table, command.data);
    }

    private void enforceCommand(in InsertRowCommand command) {
        if (command.schema.length == 0) {
            throw new Exception("schema must not be empty");
        }
        if (command.table.length == 0) {
            throw new Exception("table must not be empty");
        }
    }
}
