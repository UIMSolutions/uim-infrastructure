module uim.infrastructure.keppel.application.usecases.put_blob;

import std.datetime : Clock;
import std.base64 : Base64;
import uim.infrastructure.keppel.domain.entities.blob : Blob;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class PutBlobUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Blob execute(string repositoryName, string digest, string mediaType, const(ubyte)[] payload) {
        enforce(repositoryName.length > 0, "repository name must not be empty");
        enforce(digest.length > 0, "blob digest must not be empty");

        auto encoded = Base64.encode(payload);
        auto blob = Blob(
            digest,
            mediaType.length > 0 ? mediaType : "application/octet-stream",
            cast(long) payload.length,
            encoded.idup,
            Clock.currTime.toISOExtString()
        );

        if (!repository.upsertBlob(repositoryName, blob)) {
            throw new Exception("repository not found");
        }
        return blob;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }
}
