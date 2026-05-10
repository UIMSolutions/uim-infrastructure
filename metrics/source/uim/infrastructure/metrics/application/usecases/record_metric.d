module uim.infrastructure.metrics.application.usecases.record_metric;

import uim.infrastructure.metrics.application.dto.metric_commands : RecordMetricCommand;
import uim.infrastructure.metrics.domain.entities.metric : Metric, parseMetricType, parseMetricUnit;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;
import uim.infrastructure.metrics.domain.ports.repositories.metrics : IMetricsRepository;
import std.datetime.systime : Clock;
import std.uuid : randomUUID;

class RecordMetricUseCase {
    private IMetricsRepository repository;

    this(IMetricsRepository repository) {
        this.repository = repository;
    }

    MetricDataPoint execute(RecordMetricCommand command) {
        validateCommand(command);

        // Resolve or create the metric definition.
        auto existingPtr = repository.findMetricByName(command.name, command.resourceId);
        string metricId;
        if (existingPtr is null) {
            metricId = randomUUID().toString();
            auto metric = Metric(
                metricId,
                command.name,
                command.resourceId,
                parseMetricType(command.type),
                parseMetricUnit(command.unit),
                command.description
            );
            repository.saveMetric(metric);
        } else {
            metricId = existingPtr.id;
        }

        auto point = MetricDataPoint(
            randomUUID().toString(),
            metricId,
            command.name,
            command.resourceId,
            command.value,
            Clock.currTime().toISOExtString(),
            command.labels
        );
        repository.saveDataPoint(point);
        return point;
    }

    private void validateCommand(in RecordMetricCommand command) {
        if (command.name.length == 0) {
            throw new Exception("metric name must not be empty");
        }
    }
}

unittest {
    import uim.infrastructure.metrics.infrastructure.persistence.memory.metrics_repository : InMemoryMetricsRepository;

    auto repo = new InMemoryMetricsRepository();
    auto useCase = new RecordMetricUseCase(repo);

    RecordMetricCommand cmd;
    cmd.name       = "cpu.utilization";
    cmd.value      = 65.0;
    cmd.unit       = "percent";
    cmd.type       = "gauge";
    cmd.resourceId = "vm-001";

    auto point = useCase.execute(cmd);
    assert(point.metricName == "cpu.utilization");
    assert(point.value      == 65.0);
    assert(point.resourceId == "vm-001");
    assert(point.id.length  > 0);

    // Second call with the same name/resource should reuse the existing metric definition.
    auto point2 = useCase.execute(cmd);
    assert(point2.metricId == point.metricId);
    assert(repo.listMetrics().length == 1);
}
