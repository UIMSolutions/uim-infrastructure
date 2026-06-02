module uim.infrastructure.keppel.application.usecases.create_repository;

import std.datetime : Clock;
import std.string : toLower;
import uim.infrastructure.keppel.application.dto.commands : CreateRepositoryCommand;
import uim.infrastructure.keppel.domain.entities.repository : Repository, RepositoryVisibility;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class CreateRepositoryUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Repository execute(in CreateRepositoryCommand cmd) {
        enforce(cmd.name.length > 0, "name must not be empty");

        if (repository.exists(cmd.name)) {
            throw new Exception("repository already exists");
        }

        auto now = Clock.currTime.toISOExtString();
        auto created = Repository(
            cmd.name,
            cmd.projectId,
            parseVisibility(cmd.visibility),
            now,
            now,
            []
        );

        repository.save(created);
        return created;
    }

    private RepositoryVisibility parseVisibility(string raw) {
        auto normalized = raw.toLower();
        if (normalized == "public") return RepositoryVisibility.public_;
        return RepositoryVisibility.private_;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }
}
