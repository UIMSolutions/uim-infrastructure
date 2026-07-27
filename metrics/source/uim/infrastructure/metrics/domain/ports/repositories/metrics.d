/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.domain.ports.repositories.metrics;

import uim.infrastructure.metrics.domain.entities.metric : Metric;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;

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
