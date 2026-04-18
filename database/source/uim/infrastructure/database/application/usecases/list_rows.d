module uim.infrastructure.database.application.usecases.list_rows;

import uim.infrastructure.database.application.dto.commands : ListRowsQuery;
import uim.infrastructure.database.domain.entities.row : DatabaseRow;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;

class ListRowsUseCase {
    private IDatabaseRepository repository;

    this(IDatabaseRepository repository) {
        this.repository = repository;
    }

    DatabaseRow[] execute(in ListRowsQuery query) {
        return repository.list(query.schema, query.table);
    }
}
