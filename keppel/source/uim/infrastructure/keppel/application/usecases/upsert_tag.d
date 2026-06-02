module uim.infrastructure.keppel.application.usecases.upsert_tag;

import std.datetime : Clock;
import uim.infrastructure.keppel.application.dto.commands : UpsertTagCommand;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class UpsertTagUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    ImageTag execute(in UpsertTagCommand cmd) {
        enforce(cmd.repositoryName.length > 0, "repositoryName must not be empty");
        enforce(cmd.tag.length > 0, "tag must not be empty");
        enforce(cmd.digest.length > 0, "digest must not be empty");

        auto tag = ImageTag(
            cmd.tag,
            cmd.digest,
            cmd.sizeBytes,
            cmd.mediaType,
            Clock.currTime.toISOExtString()
        );

        if (!repository.upsertTag(cmd.repositoryName, tag)) {
            throw new Exception("repository not found");
        }
        return tag;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }
}
