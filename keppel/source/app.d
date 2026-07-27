/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.exception : collectException;
import std.string : toLower;
import std.string : fromStringz, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;
import uim.infrastructure.keppel.application.usecases.create_repository : CreateRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.delete_repository : DeleteRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.get_repository : GetRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.list_repositories : ListRepositoriesUseCase;
import uim.infrastructure.keppel.application.usecases.upsert_tag : UpsertTagUseCase;
import uim.infrastructure.keppel.application.usecases.list_tags : ListTagsUseCase;
import uim.infrastructure.keppel.application.usecases.delete_tag : DeleteTagUseCase;
import uim.infrastructure.keppel.application.usecases.put_manifest : PutManifestUseCase;
import uim.infrastructure.keppel.application.usecases.get_manifest : GetManifestUseCase;
import uim.infrastructure.keppel.application.usecases.put_blob : PutBlobUseCase;
import uim.infrastructure.keppel.application.usecases.get_blob : GetBlobUseCase;
import uim.infrastructure.keppel.infrastructure.http.controllers.keppel : KeppelController;
import uim.infrastructure.keppel.infrastructure.persistence.memory.registry_catalog_repository : InMemoryRegistryCatalogRepository;
import uim.infrastructure.keppel.infrastructure.persistence.file.registry_catalog_repository : FileRegistryCatalogRepository;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    // Outbound adapter.
    auto catalogRepo = buildRepositoryAdapter();

    // Application layer.
    auto createRepositoryUC = new CreateRepositoryUseCase(catalogRepo);
    auto deleteRepositoryUC = new DeleteRepositoryUseCase(catalogRepo);
    auto getRepositoryUC = new GetRepositoryUseCase(catalogRepo);
    auto listRepositoriesUC = new ListRepositoriesUseCase(catalogRepo);
    auto upsertTagUC = new UpsertTagUseCase(catalogRepo);
    auto listTagsUC = new ListTagsUseCase(catalogRepo);
    auto deleteTagUC = new DeleteTagUseCase(catalogRepo);
    auto putManifestUC = new PutManifestUseCase(catalogRepo);
    auto getManifestUC = new GetManifestUseCase(catalogRepo);
    auto putBlobUC = new PutBlobUseCase(catalogRepo);
    auto getBlobUC = new GetBlobUseCase(catalogRepo);

    // Inbound HTTP adapter.
    auto controller = new KeppelController(
        createRepositoryUC,
        deleteRepositoryUC,
        getRepositoryUC,
        listRepositoriesUC,
        upsertTagUC,
        listTagsUC,
        deleteTagUC,
        putManifestUC,
        getManifestUC,
        putBlobUC,
        getBlobUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Keppel-inspired registry service starting on %s:%d",
        settings.bindAddresses[0], settings.port);

    listenHTTP(settings, router);
    runApplication();
}

private IRegistryCatalogRepository buildRepositoryAdapter() {
    auto backend = readEnv("PERSISTENCE_BACKEND", "file").toLower();
    if (backend == "memory") {
        return new InMemoryRegistryCatalogRepository();
    }

    auto dbFile = readEnv("CATALOG_DB_FILE", ".keppel/catalog.json");
    return new FileRegistryCatalogRepository(dbFile);
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) return cast(ushort) 9312;
    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 9312;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readEnv(string key, string fallback) {
    auto ckey = toStringz(key);
    auto raw = getenv(ckey);
    return raw is null ? fallback : fromStringz(raw).idup;
}
