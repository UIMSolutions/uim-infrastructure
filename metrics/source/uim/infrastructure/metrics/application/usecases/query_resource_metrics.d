module uim.infrastructure.metrics.application.usecases.query_resource_metrics;

import metrics_service.application.dto.metric_commands : QueryResourceQuery;
import metrics_service.domain.entities.metric_data_point : MetricDataPoint;
import metrics_service.domain.ports.repositories.metrics : IMetricsRepository;

class QueryResourceMetricsUseCase {
    private IMetricsRepository repository;

    this(IMetricsRepository repository) {
        this.repository = repository;
    }

    MetricDataPoint[] execute(in QueryResourceQuery query) {
        if (query.resourceId.length == 0) {
            throw new Exception("resourceId must not be empty");
        }
        return repository.getByResource(query.resourceId);
    }
}
