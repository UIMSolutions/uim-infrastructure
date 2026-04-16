module app;

import monitoring_service.application.usecases.deregister_check : DeregisterCheckUseCase;
import monitoring_service.application.usecases.list_check_results : ListCheckResultsUseCase;
import monitoring_service.application.usecases.list_checks : ListChecksUseCase;
import monitoring_service.application.usecases.register_check : RegisterCheckUseCase;
import monitoring_service.application.usecases.run_check : RunCheckUseCase;
import monitoring_service.infrastructure.http.controllers.monitoring : MonitoringController;
import monitoring_service.infrastructure.persistence.memory.check_repository : InMemoryCheckRepository;
import monitoring_service.infrastructure.probing.http_check_runner : HttpCheckRunner;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryCheckRepository();
    auto runner     = new HttpCheckRunner();

    auto controller = new MonitoringController(
        new RegisterCheckUseCase(repository),
        new DeregisterCheckUseCase(repository),
        new ListChecksUseCase(repository),
        new RunCheckUseCase(repository, runner),
        new ListCheckResultsUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Monitoring service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
