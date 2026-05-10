module uim.infrastructure.maia.application.usecases.list_labels;

import uim.infrastructure.maia.application.dto.maia_commands : ListLabelsCommand;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;

class ListLabelsUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    string[] execute(ListLabelsCommand command, Tenant tenant) {
        return repository.listLabels(tenant);
    }
}
