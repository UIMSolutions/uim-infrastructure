/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
