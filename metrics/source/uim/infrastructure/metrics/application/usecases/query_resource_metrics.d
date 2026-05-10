module uim.infrastructure.metrics.application.usecases.query_resource_metrics;

import uim.infrastructure.metrics.application.dto.metric_commands : QueryResourceQuery;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;
import uim.infrastructure.metrics.domain.ports.repositories.metrics : IMetricsRepository;

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
