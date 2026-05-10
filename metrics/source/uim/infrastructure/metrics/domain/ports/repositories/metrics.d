module uim.infrastructure.metrics.domain.ports.repositories.metrics;

import metrics_service.domain.entities.metric : Metric;
import metrics_service.domain.entities.metric_data_point : MetricDataPoint;

/// Hexagonal port: driven-side contract for metrics persistence.
interface IMetricsRepository {
    /// Persist a metric definition.
    void saveMetric(in Metric metric);

    /// Return all registered metric definitions.
    Metric[] listMetrics();

    /// Find a metric definition by name and resourceId; returns null when absent.
    Metric* findMetricByName(string name, string resourceId);

    /// Persist a single data-point observation.
    void saveDataPoint(in MetricDataPoint point);

    /// Return all data points recorded under a given metric name.
    MetricDataPoint[] getSeriesByName(string name);

    /// Return all data points for a metric name scoped to one resource.
    MetricDataPoint[] getSeriesByNameAndResource(string name, string resourceId);

    /// Return all data points recorded for a given resource.
    MetricDataPoint[] getByResource(string resourceId);
}
