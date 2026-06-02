module uim.infrastructure.keppel.application.usecases.list_repositories;

import uim.infrastructure.keppel.domain.entities.repository : Repository;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class ListRepositoriesUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Repository[] execute(string projectId = "") {
        return repository.list(projectId);
    }
}
