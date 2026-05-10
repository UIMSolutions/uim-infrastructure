module uim.infrastructure.metrics.application.dto.metric_commands;

/// Command to record a single metric observation.
struct RecordMetricCommand {
    string         name;
    double         value;
    string         unit;
    string         type;
    string         resourceId;
    string[string] labels;
    string         description;
}

/// Query to retrieve time-series data for a metric name.
struct GetSeriesQuery {
    string metricName;
    string resourceId; // optional; empty means all resources
}

/// Query to retrieve all metric data for a specific resource.
struct QueryResourceQuery {
    string resourceId;
}
