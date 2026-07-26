module app;

import core.stdc.stdlib : getenv;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import vibe.core.core : runApplication;
import vibe.core.log : logInfo;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings;

import uim.infrastructure.gardener.application.usecases :
    CreateGardenUseCase,
    CreateProjectUseCase,
    CreateSecretUseCase,
    CreateCertificateUseCase,
    CreateSeedUseCase,
    CreateShootUseCase,
    DeleteGardenUseCase,
    DeleteProjectUseCase,
    DeleteSecretUseCase,
    DeleteCertificateUseCase,
    DeleteSeedUseCase,
    DeleteShootUseCase,
    GetGardenUseCase,
    GetProjectUseCase,
    GetSecretUseCase,
    GetCertificateUseCase,
    GetSeedUseCase,
    GetShootUseCase,
    ListGardensUseCase,
    ListProjectsUseCase,
    ListSecretsUseCase,
    ListCertificatesUseCase,
    ListSeedsUseCase,
    ListShootsUseCase,
    ReconcileShootUseCase,
    UpdateShootStatusUseCase;
import uim.infrastructure.gardener.infrastructure.adapters.http.controller : GardenerController;
import uim.infrastructure.gardener.infrastructure.adapters.inmemory :
    InMemoryGardenRepository,
    InMemoryProjectRepository,
    InMemorySecretRepository,
    InMemoryCertificateRepository,
    InMemorySeedRepository,
    InMemoryShootRepository;

void main() {
    auto settings = new HTTPServerSettings();
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto gardenRepository = new InMemoryGardenRepository();
    auto projectRepository = new InMemoryProjectRepository();
    auto secretRepository = new InMemorySecretRepository();
    auto certificateRepository = new InMemoryCertificateRepository();
    auto seedRepository = new InMemorySeedRepository();
    auto shootRepository = new InMemoryShootRepository();

    auto controller = new GardenerController(
        new CreateGardenUseCase(gardenRepository),
        new ListGardensUseCase(gardenRepository),
        new GetGardenUseCase(gardenRepository),
        new DeleteGardenUseCase(gardenRepository),
        new CreateProjectUseCase(projectRepository),
        new ListProjectsUseCase(projectRepository),
        new GetProjectUseCase(projectRepository),
        new DeleteProjectUseCase(projectRepository),
        new CreateSecretUseCase(secretRepository),
        new ListSecretsUseCase(secretRepository),
        new GetSecretUseCase(secretRepository),
        new DeleteSecretUseCase(secretRepository),
        new CreateCertificateUseCase(certificateRepository),
        new ListCertificatesUseCase(certificateRepository),
        new GetCertificateUseCase(certificateRepository),
        new DeleteCertificateUseCase(certificateRepository),
        new CreateSeedUseCase(seedRepository),
        new ListSeedsUseCase(seedRepository),
        new GetSeedUseCase(seedRepository),
        new DeleteSeedUseCase(seedRepository),
        new CreateShootUseCase(shootRepository),
        new ListShootsUseCase(shootRepository),
        new GetShootUseCase(shootRepository),
        new ReconcileShootUseCase(shootRepository),
        new UpdateShootStatusUseCase(shootRepository),
        new DeleteShootUseCase(shootRepository),
    );

    auto router = new URLRouter();
    controller.registerRoutes(router);

    auto listener = listenHTTP(settings, router);
    scope(exit) listener.stopListening();

    logInfo("UIM Gardener Service running on http://%s:%d", settings.bindAddresses[0], settings.port);

    runApplication();
}

private auto listenHTTP(HTTPServerSettings settings, URLRouter router) {
    import vibe.http.server : listenHTTP;

    return listenHTTP(settings, router);
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
    return raw is null ? "0.0.0.0" : fromStringz(raw).idup;
}
