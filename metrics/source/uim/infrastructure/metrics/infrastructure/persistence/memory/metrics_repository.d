module uim.infrastructure.metrics.infrastructure.persistence.memory.metrics_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.metrics.domain.entities.metric : Metric;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;
import uim.infrastructure.metrics.domain.ports.repositories.metrics : IMetricsRepository;

class InMemoryMetricsRepository : IMetricsRepository {
    private Metric[]          metrics;
    private MetricDataPoint[] dataPoints;
    private Mutex             mutex;

    this() { mutex = new Mutex; }

    override void saveMetric(in Metric metric) {
        Metric m = metric;
        synchronized (mutex) { metrics ~= m; }
    }

    override Metric[] listMetrics() {
        synchronized (mutex) { return metrics.dup; }
    }

    override Metric* findMetricByName(string name, string resourceId) {
        synchronized (mutex) {
            foreach (ref m; metrics) {
                if (m.name == name && m.resourceId == resourceId) return &m;
            }
            return null;
        }
    }

    override void saveDataPoint(in MetricDataPoint point) {
        string[string] lbls;
        foreach (k, v; point.labels) lbls[k] = v;
        auto p = MetricDataPoint(point.id, point.metricId, point.metricName, point.resourceId, point.value, point.timestamp, lbls);
        synchronized (mutex) { dataPoints ~= p; }
    }

    override MetricDataPoint[] getSeriesByName(string name) {
        synchronized (mutex) {
            MetricDataPoint[] result;
            foreach (dp; dataPoints) {
                if (dp.metricName == name) result ~= dp;
            }
            return result;
        }
    }

    override MetricDataPoint[] getSeriesByNameAndResource(string name, string resourceId) {
        synchronized (mutex) {
            MetricDataPoint[] result;
            foreach (dp; dataPoints) {
                if (dp.metricName == name && dp.resourceId == resourceId) result ~= dp;
            }
            return result;
        }
    }

    override MetricDataPoint[] getByResource(string resourceId) {
        synchronized (mutex) {
            MetricDataPoint[] result;
            foreach (dp; dataPoints) {
                if (dp.resourceId == resourceId) result ~= dp;
            }
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.metrics.domain.entities.metric : MetricType, MetricUnit;

    auto repo = new InMemoryMetricsRepository();
    repo.saveMetric(Metric("m1", "cpu.util", "vm-001", MetricType.gauge, MetricUnit.percent, "CPU"));
    repo.saveMetric(Metric("m2", "mem.used", "vm-001", MetricType.gauge, MetricUnit.bytes,   "Mem"));

    assert(repo.listMetrics().length == 2);

    auto ptr = repo.findMetricByName("cpu.util", "vm-001");
    assert(ptr !is null && ptr.id == "m1");
    assert(repo.findMetricByName("no.such", "vm-001") is null);

    repo.saveDataPoint(MetricDataPoint("dp1", "m1", "cpu.util", "vm-001", 72.5, "2026-05-10T10:00:00Z", null));
    repo.saveDataPoint(MetricDataPoint("dp2", "m1", "cpu.util", "vm-002", 45.0, "2026-05-10T10:00:00Z", null));
    repo.saveDataPoint(MetricDataPoint("dp3", "m2", "mem.used", "vm-001", 2.0e9, "2026-05-10T10:00:00Z", null));

    assert(repo.getSeriesByName("cpu.util").length == 2);
    assert(repo.getSeriesByNameAndResource("cpu.util", "vm-001").length == 1);
    assert(repo.getByResource("vm-001").length == 2);
}
