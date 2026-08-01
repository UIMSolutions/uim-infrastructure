module app;

import uim.infrastructure.cds_service.application.usecases.create_definition : CreateDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.delete_definition : DeleteDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.get_definition : GetDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.list_definitions : ListDefinitionsUseCase;
import uim.infrastructure.cds_service.infrastructure.http.controllers.api_controller : ApiController;
import uim.infrastructure.cds_service.infrastructure.http.controllers.web_controller : WebController;
import uim.infrastructure.cds_service.infrastructure.persistence.memory.cds_definition_repository :
    InMemoryCdsDefinitionRepository;
import std.conv : to;
import std.exception : collectException;
import std.file : write;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import core.sys.posix.unistd : getpid;
import vibe.vibe;

void main() {
    writePidFile();

    auto settings = new HTTPServerSettings();
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryCdsDefinitionRepository();
    auto createUseCase = new CreateDefinitionUseCase(repository);
    auto listUseCase = new ListDefinitionsUseCase(repository);
    auto getUseCase = new GetDefinitionUseCase(repository);
    auto deleteUseCase = new DeleteDefinitionUseCase(repository);

    auto apiController = new ApiController(createUseCase, listUseCase, getUseCase, deleteUseCase);
    auto webController = new WebController(
        createUseCase,
        listUseCase,
        getUseCase,
        readDefaultNamespace()
    );

    auto router = new URLRouter();
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("CDS service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private void writePidFile() {
    auto raw = getenv("PID_FILE");
    string path = raw is null ? "/var/run/uim-cds-service.pid" : fromStringz(raw).idup;
    try {
        write(path, to!string(getpid()));
    } catch (Exception) {
        // PID file write is best-effort.
    }
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

private string readDefaultNamespace() {
    auto raw = getenv("CDS_DEFAULT_NAMESPACE");
    return raw is null ? "uim.cds".idup : fromStringz(raw).idup;
}
