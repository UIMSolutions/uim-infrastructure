/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.domain.entities.metric;

import std.conv : to;
import std.string : toLower;

/// Classification of a metric's behaviour.
enum MetricType {
    gauge,     /// Point-in-time value (e.g. CPU utilisation %)
    counter,   /// Monotonically increasing total (e.g. total requests)
    histogram  /// Distribution of observed values
}

/// Physical unit of a metric value.
enum MetricUnit {
    percent,
    bytes,
    bytes_per_sec,
    milliseconds,
    count,
    none_
}

/// Registered metric definition tied to a specific resource.
struct Metric {
    string     id;
    string     name;
    string     resourceId;
    MetricType type;
    MetricUnit unit;
    string     description;
}

/// Parse a metric type from a string, defaulting to gauge for unknown values.
MetricType parseMetricType(string raw) {
    switch (raw.toLower()) {
        case "gauge":     return MetricType.gauge;
        case "counter":   return MetricType.counter;
        case "histogram": return MetricType.histogram;
        default:          return MetricType.gauge;
    }
}

/// Parse a metric unit from a string, defaulting to none_ for unknown values.
MetricUnit parseMetricUnit(string raw) {
    switch (raw.toLower()) {
        case "percent":       return MetricUnit.percent;
        case "bytes":         return MetricUnit.bytes;
        case "bytes_per_sec": return MetricUnit.bytes_per_sec;
        case "milliseconds":  return MetricUnit.milliseconds;
        case "ms":            return MetricUnit.milliseconds;
        case "count":         return MetricUnit.count;
        default:              return MetricUnit.none_;
    }
}

unittest {
    assert(parseMetricType("gauge")     == MetricType.gauge);
    assert(parseMetricType("counter")   == MetricType.counter);
    assert(parseMetricType("histogram") == MetricType.histogram);
    assert(parseMetricType("unknown")   == MetricType.gauge);

    assert(parseMetricUnit("percent")       == MetricUnit.percent);
    assert(parseMetricUnit("bytes")         == MetricUnit.bytes);
    assert(parseMetricUnit("bytes_per_sec") == MetricUnit.bytes_per_sec);
    assert(parseMetricUnit("ms")            == MetricUnit.milliseconds);
    assert(parseMetricUnit("count")         == MetricUnit.count);
    assert(parseMetricUnit("unknown")       == MetricUnit.none_);

    auto m = Metric("m1", "cpu.utilization", "vm-001", MetricType.gauge, MetricUnit.percent, "CPU %");
    assert(m.name       == "cpu.utilization");
    assert(m.resourceId == "vm-001");
    assert(m.type       == MetricType.gauge);
    assert(m.unit       == MetricUnit.percent);
}
