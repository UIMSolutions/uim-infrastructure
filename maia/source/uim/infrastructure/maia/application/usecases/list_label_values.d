module uim.infrastructure.maia.application.usecases.list_label_values;

import uim.infrastructure.maia.application.dto.maia_commands : ListLabelValuesCommand;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;

class ListLabelValuesUseCase {
    private ITimeSeriesRepository repository;

    this(ITimeSeriesRepository repository) {
        this.repository = repository;
    }

    string[] execute(ListLabelValuesCommand command, Tenant tenant) {
        if (command.labelName.length == 0) {
            throw new Exception("label name must not be empty");
        }
        return repository.listLabelValues(command.labelName, tenant);
    }
}
