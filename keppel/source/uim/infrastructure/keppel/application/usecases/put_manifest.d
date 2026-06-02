module uim.infrastructure.keppel.application.usecases.put_manifest;

import std.datetime : Clock;
import std.string : startsWith;
import uim.infrastructure.keppel.domain.entities.manifest : Manifest;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class PutManifestUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Manifest execute(
        string repositoryName,
        string reference,
        string digest,
        string mediaType,
        string content
    ) {
        enforce(repositoryName.length > 0, "repository name must not be empty");
        enforce(reference.length > 0, "manifest reference must not be empty");
        enforce(digest.length > 0, "manifest digest must not be empty");

        auto manifest = Manifest(
            reference,
            digest,
            mediaType.length > 0 ? mediaType : "application/vnd.oci.image.manifest.v1+json",
            content,
            Clock.currTime.toISOExtString()
        );

        if (!repository.upsertManifest(repositoryName, reference, manifest)) {
            throw new Exception("repository not found");
        }

        // Keep tag listing in sync when reference is a tag and not a digest.
        if (!reference.startsWith("sha256:")) {
            auto tag = ImageTag(
                reference,
                digest,
                cast(long) content.length,
                manifest.mediaType,
                Clock.currTime.toISOExtString()
            );
            repository.upsertTag(repositoryName, tag);
        }

        return manifest;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }
}
