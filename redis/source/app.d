module app;

import redis_service.application.usecases.delete_value : DeleteValueUseCase;
import redis_service.application.usecases.get_value : GetValueUseCase;
import redis_service.application.usecases.list_keys : ListKeysUseCase;
import redis_service.application.usecases.set_value : SetValueUseCase;
import redis_service.infrastructure.http.controllers.redis : RedisController;
import redis_service.infrastructure.persistence.memory.cache_repository : InMemoryCacheRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryCacheRepository();

    auto controller = new RedisController(
        new SetValueUseCase(repository),
        new GetValueUseCase(repository),
        new DeleteValueUseCase(repository),
        new ListKeysUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Redis service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
