module uim.infrastructure.database.application.usecases.find_row;

import uim.infrastructure.database.application.dto.commands : FindRowQuery;
import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class FindRowUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    DatabaseRow execute(in FindRowQuery query) {
        return repository.findById(query.schema, query.table, query.id);
    }
}
