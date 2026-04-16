module app;

import lb_service.application.usecases.deregister_backend : DeregisterBackendUseCase;
import lb_service.application.usecases.list_backends : ListBackendsUseCase;
import lb_service.application.usecases.register_backend : RegisterBackendUseCase;
import lb_service.application.usecases.select_backend : SelectBackendUseCase;
import lb_service.infrastructure.http.controllers.load_balancer : LoadBalancerController;
import lb_service.infrastructure.persistence.memory.backend_repository : InMemoryBackendRepository;
import lb_service.infrastructure.routing.round_robin_selector : RoundRobinSelector;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryBackendRepository();
    auto selector   = new RoundRobinSelector();

    auto controller = new LoadBalancerController(
        new RegisterBackendUseCase(repository),
        new DeregisterBackendUseCase(repository),
        new ListBackendsUseCase(repository),
        new SelectBackendUseCase(repository, selector)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Load-balancing service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
