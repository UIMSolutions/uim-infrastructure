module app;

import uim.infrastructure.database.application.usecases.insert_row : InsertRowUseCase;
import uim.infrastructure.database.application.usecases.find_row : FindRowUseCase;
import uim.infrastructure.database.application.usecases.find_rows : FindRowsUseCase;
import uim.infrastructure.database.application.usecases.list_rows : ListRowsUseCase;
import uim.infrastructure.database.application.usecases.update_row : UpdateRowUseCase;
import uim.infrastructure.database.application.usecases.delete_row : DeleteRowUseCase;
import uim.infrastructure.database.infrastructure.http.controllers.database : DatabaseController;
import uim.infrastructure.database.infrastructure.persistence.memory.database_repository : InMemoryDatabaseRepository;
import uim.infrastructure.database.domain.ports.database_repository : IDatabaseRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    IDatabaseRepository repository = createRepository();

    auto controller = new DatabaseController(
        new InsertRowUseCase(repository),
        new FindRowUseCase(repository),
        new FindRowsUseCase(repository),
        new ListRowsUseCase(repository),
        new UpdateRowUseCase(repository),
        new DeleteRowUseCase(repository),
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Database service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

/// Select the repository adapter based on environment configuration.
/// When DATABASE_URL is set, a future SQL adapter can be wired here;
/// otherwise the in-memory adapter is used for local development and testing.
private IDatabaseRepository createRepository() {
    auto dbUrl = getenv("DATABASE_URL");
    if (dbUrl !is null) {
        // Placeholder: swap for a real PostgreSQL/MySQL adapter once available.
        logInfo("DATABASE_URL is set but a live SQL adapter is not yet wired — using in-memory repository");
    } else {
        logInfo("No DATABASE_URL set, using in-memory repository");
    }
    return new InMemoryDatabaseRepository();
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
