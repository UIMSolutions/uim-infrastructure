/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.domain.entities.metric_data_point;

/// A single recorded observation for a named metric on a resource.
struct MetricDataPoint {
    string      id;
    string      metricId;
    string      metricName;
    string      resourceId;
    double      value;
    string      timestamp;
    string[string] labels;
}

unittest {
    string[string] lbl = ["region": "us-east-1", "env": "prod"];
    auto dp = MetricDataPoint("dp1", "m1", "cpu.utilization", "vm-001", 72.5,
                              "2026-05-10T10:00:00Z", lbl);
    assert(dp.value      == 72.5);
    assert(dp.metricName == "cpu.utilization");
    assert(dp.labels["region"] == "us-east-1");
}
