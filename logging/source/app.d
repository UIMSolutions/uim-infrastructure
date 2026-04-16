module app;

import log_service.application.usecases.list_logs : ListLogsUseCase;
import log_service.application.usecases.query_logs : QueryLogsUseCase;
import log_service.application.usecases.write_log : WriteLogUseCase;
import log_service.infrastructure.http.controllers.logging : LoggingController;
import log_service.infrastructure.persistence.memory.logs_repository : InMemoryLogsRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryLogsRepository();

    auto controller = new LoggingController(
        new WriteLogUseCase(repository),
        new QueryLogsUseCase(repository),
        new ListLogsUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Logging service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
