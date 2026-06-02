module uim.infrastructure.keppel.tests.keppel_tests;

import std.file : remove, rmdirRecurse, exists;
import std.path : buildPath;
import std.datetime : Clock;
import std.conv : to;
import uim.infrastructure.keppel.application.dto.commands : CreateRepositoryCommand;
import uim.infrastructure.keppel.application.usecases.create_repository : CreateRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.list_repositories : ListRepositoriesUseCase;
import uim.infrastructure.keppel.application.usecases.put_manifest : PutManifestUseCase;
import uim.infrastructure.keppel.application.usecases.get_manifest : GetManifestUseCase;
import uim.infrastructure.keppel.application.usecases.put_blob : PutBlobUseCase;
import uim.infrastructure.keppel.application.usecases.get_blob : GetBlobUseCase;
import uim.infrastructure.keppel.infrastructure.persistence.memory.registry_catalog_repository : InMemoryRegistryCatalogRepository;
import uim.infrastructure.keppel.infrastructure.persistence.file.registry_catalog_repository : FileRegistryCatalogRepository;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;

unittest {
    auto repo = new InMemoryRegistryCatalogRepository();
    auto createRepositoryUC = new CreateRepositoryUseCase(repo);
    auto listRepositoriesUC = new ListRepositoriesUseCase(repo);

    auto created = createRepositoryUC.execute(CreateRepositoryCommand("proj/api", "p1", "private"));
    assert(created.name == "proj/api");

    assert(repo.upsertTag("proj/api", ImageTag("latest", "sha256:a", 100, "application/json", Clock.currTime.toISOExtString())));

    auto repos = listRepositoriesUC.execute("p1");
    assert(repos.length == 1);
    assert(repos[0].tags.length == 1);
    assert(repos[0].tags[0].name == "latest");
}

unittest {
    auto repo = new InMemoryRegistryCatalogRepository();
    auto createRepositoryUC = new CreateRepositoryUseCase(repo);
    createRepositoryUC.execute(CreateRepositoryCommand("proj/worker", "p2", "public"));

    auto putManifestUC = new PutManifestUseCase(repo);
    auto getManifestUC = new GetManifestUseCase(repo);
    auto putBlobUC = new PutBlobUseCase(repo);
    auto getBlobUC = new GetBlobUseCase(repo);

    auto manifest = putManifestUC.execute(
        "proj/worker",
        "1.0.0",
        "sha256:abc",
        "application/vnd.oci.image.manifest.v1+json",
        "{\"schemaVersion\":2}"
    );
    assert(manifest.reference == "1.0.0");

    auto manifestPtr = getManifestUC.execute("proj/worker", "1.0.0");
    assert(manifestPtr !is null);
    assert(manifestPtr.digest == "sha256:abc");

    const(ubyte)[] raw = [cast(ubyte) 'h', cast(ubyte) 'e', cast(ubyte) 'l', cast(ubyte) 'l', cast(ubyte) 'o'];
    auto blob = putBlobUC.execute("proj/worker", "sha256:def", "application/octet-stream", raw);
    assert(blob.sizeBytes == 5);

    auto payload = getBlobUC.execute("proj/worker", "sha256:def");
    assert(cast(string) payload.payload == "hello");
}

unittest {
    auto unique = "keppel-test-" ~ Clock.currTime.toUnixTime().to!string;
    auto baseDir = buildPath(".keppel", unique);
    auto filePath = buildPath(baseDir, "catalog.json");

    {
        auto repo = new FileRegistryCatalogRepository(filePath);
        auto createRepositoryUC = new CreateRepositoryUseCase(repo);
        createRepositoryUC.execute(CreateRepositoryCommand("persisted/repo", "persisted", "private"));
        assert(repo.upsertTag("persisted/repo", ImageTag("stable", "sha256:111", 10, "application/json", Clock.currTime.toISOExtString())));
    }

    {
        auto repo = new FileRegistryCatalogRepository(filePath);
        auto listRepositoriesUC = new ListRepositoriesUseCase(repo);
        auto repos = listRepositoriesUC.execute("persisted");
        assert(repos.length == 1);
        assert(repos[0].name == "persisted/repo");
        assert(repos[0].tags.length == 1);
        assert(repos[0].tags[0].name == "stable");
    }

    if (exists(baseDir)) {
        rmdirRecurse(baseDir);
    }
}
