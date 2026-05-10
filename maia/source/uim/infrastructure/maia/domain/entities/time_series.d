module uim.infrastructure.maia.domain.entities.time_series;

/// A named, labelled measurement stream, identified by its complete label set.
/// The special label "__name__" carries the metric name.
/// Multi-tenancy is enforced via the "project_id" and "domain_id" labels.
struct TimeSeries {
    string         id;
    string[string] labels;

    string name()      const { return labels.get("__name__", ""); }
    string projectId() const { return labels.get("project_id", ""); }
    string domainId()  const { return labels.get("domain_id",  ""); }
}

unittest {
    string[string] lbl = ["__name__": "cpu_util", "project_id": "p1", "job": "os"];
    auto ts = TimeSeries("ts1", lbl);
    assert(ts.name()      == "cpu_util");
    assert(ts.projectId() == "p1");
    assert(ts.domainId()  == "");
}
