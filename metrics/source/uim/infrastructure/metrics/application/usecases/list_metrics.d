/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.application.usecases.list_metrics;

import uim.infrastructure.metrics.domain.entities.metric : Metric;
import uim.infrastructure.metrics.domain.ports.repositories.metrics : IMetricsRepository;

class ListMetricsUseCase {
    private IMetricsRepository repository;

    this(IMetricsRepository repository) {
        this.repository = repository;
    }

    Metric[] execute() {
        return repository.listMetrics();
    }
}
