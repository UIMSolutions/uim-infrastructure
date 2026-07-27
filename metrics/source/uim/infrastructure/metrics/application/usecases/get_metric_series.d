/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.application.usecases.get_metric_series;

import uim.infrastructure.metrics.application.dto.metric_commands : GetSeriesQuery;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;
import uim.infrastructure.metrics.domain.ports.repositories.metrics : IMetricsRepository;

class GetMetricSeriesUseCase {
    private IMetricsRepository repository;

    this(IMetricsRepository repository) {
        this.repository = repository;
    }

    MetricDataPoint[] execute(in GetSeriesQuery query) {
        if (query.metricName.length == 0) {
            throw new Exception("metric name must not be empty");
        }
        if (query.resourceId.length > 0) {
            return repository.getSeriesByNameAndResource(query.metricName, query.resourceId);
        }
        return repository.getSeriesByName(query.metricName);
    }
}
