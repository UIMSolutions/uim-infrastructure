module app;

import uim.infrastructure.metrics.application.usecases.get_metric_series : GetMetricSeriesUseCase;
import uim.infrastructure.metrics.application.usecases.list_metrics : ListMetricsUseCase;
import uim.infrastructure.metrics.application.usecases.query_resource_metrics : QueryResourceMetricsUseCase;
import uim.infrastructure.metrics.application.usecases.record_metric : RecordMetricUseCase;
import uim.infrastructure.metrics.infrastructure.http.controllers.metrics : MetricsController;
import uim.infrastructure.metrics.infrastructure.persistence.memory.metrics_repository : InMemoryMetricsRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryMetricsRepository();

    auto controller = new MetricsController(
        new RecordMetricUseCase(repository),
        new ListMetricsUseCase(repository),
        new GetMetricSeriesUseCase(repository),
        new QueryResourceMetricsUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Metrics service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
