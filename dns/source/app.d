module app;

import dns_service.application.use_cases.list_records : ListRecordsUseCase;
import dns_service.application.use_cases.register_record : RegisterRecordUseCase;
import dns_service.application.use_cases.resolve_record : ResolveRecordUseCase;
import dns_service.infrastructure.http.dns_controller : DNSController;
import dns_service.infrastructure.persistence.in_memory_dns_repository : InMemoryDNSRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import std.array : idup;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryDNSRepository();

    auto controller = new DNSController(
        new RegisterRecordUseCase(repository),
        new ResolveRecordUseCase(repository),
        new ListRecordsUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("DNS service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
    return err is null ? parsed : cast(ushort)8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
