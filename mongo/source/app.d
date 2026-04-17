module app;

import uim.infrastructure.mongo.application.usecases.insert_document : InsertDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.find_document : FindDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.find_documents : FindDocumentsUseCase;
import uim.infrastructure.mongo.application.usecases.list_documents : ListDocumentsUseCase;
import uim.infrastructure.mongo.application.usecases.update_document : UpdateDocumentUseCase;
import uim.infrastructure.mongo.application.usecases.delete_document : DeleteDocumentUseCase;
import uim.infrastructure.mongo.infrastructure.http.controllers.mongo : MongoController;
import uim.infrastructure.mongo.infrastructure.persistence.memory.mongo_repository : InMemoryMongoRepository;
import uim.infrastructure.mongo.domain.ports.mongo_repository : IMongoRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    IMongoRepository repository = createRepository();

    auto controller = new MongoController(
        new InsertDocumentUseCase(repository),
        new FindDocumentUseCase(repository),
        new FindDocumentsUseCase(repository),
        new ListDocumentsUseCase(repository),
        new UpdateDocumentUseCase(repository),
        new DeleteDocumentUseCase(repository),
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("MongoDB service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

/// Instantiate the repository adapter based on environment configuration.
/// When MONGO_URI is set, connect to a real MongoDB instance; otherwise
/// fall back to the in-memory adapter for local development and testing.
private IMongoRepository createRepository() {
    auto mongoUri = getenv("MONGO_URI");
    if (mongoUri !is null) {
        import uim.infrastructure.mongo.infrastructure.persistence.mongodb.mongo_repository : VibeMongoRepository;
        auto uri = fromStringz(mongoUri).idup;
        logInfo("Connecting to MongoDB at %s", uri);
        return new VibeMongoRepository(uri);
    }

    logInfo("No MONGO_URI set, using in-memory repository");
    return new InMemoryMongoRepository();
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
