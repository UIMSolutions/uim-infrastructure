module uim.infrastructure.database.application.usecases.find_rows;

import uim.infrastructure.database.application.dto.commands : FindRowsQuery;
import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class FindRowsUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    DatabaseRow[] execute(in FindRowsQuery query) {
        return repository.find(query.schema, query.table, query.filter);
    }
}
