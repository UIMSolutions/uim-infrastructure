/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
