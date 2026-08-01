module app;

import uim.infrastructure.acdoca_service.application.usecases.create_journal_entry :
    CreateJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.delete_journal_entry :
    DeleteJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.get_journal_entry :
    GetJournalEntryUseCase;
import uim.infrastructure.acdoca_service.application.usecases.list_journal_entries :
    ListJournalEntriesUseCase;
import uim.infrastructure.acdoca_service.domain.ports.repositories.journal_entry_repository :
    IJournalEntryRepository;
import uim.infrastructure.acdoca_service.infrastructure.http.security.write_auth_middleware :
    WriteAuthMiddleware;
import uim.infrastructure.acdoca_service.infrastructure.http.controllers.api_controller : ApiController;
import uim.infrastructure.acdoca_service.infrastructure.http.controllers.web_controller : WebController;
import uim.infrastructure.acdoca_service.infrastructure.persistence.memory.journal_entry_repository :
    InMemoryJournalEntryRepository;
import uim.infrastructure.acdoca_service.infrastructure.persistence.postgresql.journal_entry_repository :
    PostgreSqlJournalEntryRepository;
import std.conv : to;
import std.exception : collectException;
import std.file : write;
import std.string : fromStringz, toLower, toStringz;
import core.stdc.stdlib : getenv;
import core.sys.posix.unistd : getpid;
import vibe.vibe;

void main() {
    writePidFile();

    auto settings = new HTTPServerSettings();
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    IJournalEntryRepository repository;
    if (readStorageBackend() == "postgres") {
        repository = new PostgreSqlJournalEntryRepository(readPostgresDsn());
    } else {
        repository = new InMemoryJournalEntryRepository();
    }

    auto authMiddleware = new WriteAuthMiddleware(
        readEnv("AUTH_MODE", "none"),
        readEnv("AUTH_TOKEN", ""),
        readEnv("AUTH_JWT_TOKEN", ""),
        readEnv("AUTH_REQUIRED_SCOPE", "acdoca.write"),
        readEnv("OAUTH2_TOKEN_MAP", "")
    );

    auto createUseCase = new CreateJournalEntryUseCase(repository);
    auto listUseCase = new ListJournalEntriesUseCase(repository);
    auto getUseCase = new GetJournalEntryUseCase(repository);
    auto deleteUseCase = new DeleteJournalEntryUseCase(repository);

    auto apiController = new ApiController(
        createUseCase,
        listUseCase,
        getUseCase,
        deleteUseCase,
        authMiddleware
    );
    auto webController = new WebController(
        createUseCase,
        listUseCase,
        getUseCase,
        readDefaultCompanyCode(),
        authMiddleware
    );

    auto router = new URLRouter();
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("ACDOCA service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private void writePidFile() {
    auto raw = getenv("PID_FILE");
    string path = raw is null ? "/var/run/uim-acdoca-service.pid" : fromStringz(raw).idup;
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

private string readDefaultCompanyCode() {
    auto raw = getenv("ACDOCA_DEFAULT_COMPANY_CODE");
    return raw is null ? "1000".idup : fromStringz(raw).idup;
}

private string readStorageBackend() {
    return readEnv("STORAGE_BACKEND", "memory").toLower;
}

private string readPostgresDsn() {
    return readEnv("POSTGRES_DSN", "postgresql://postgres:postgres@localhost:5432/acdoca");
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
