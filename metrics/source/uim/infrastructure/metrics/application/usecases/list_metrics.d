module uim.infrastructure.metrics.application.usecases.list_metrics;

import metrics_service.domain.entities.metric : Metric;
import metrics_service.domain.ports.repositories.metrics : IMetricsRepository;

class ListMetricsUseCase {
    private IMetricsRepository repository;

    this(IMetricsRepository repository) {
        this.repository = repository;
    }

    Metric[] execute() {
        return repository.listMetrics();
    }
}
