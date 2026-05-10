module uim.infrastructure.metrics.application.usecases.get_metric_series;

import metrics_service.application.dto.metric_commands : GetSeriesQuery;
import metrics_service.domain.entities.metric_data_point : MetricDataPoint;
import metrics_service.domain.ports.repositories.metrics : IMetricsRepository;

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
