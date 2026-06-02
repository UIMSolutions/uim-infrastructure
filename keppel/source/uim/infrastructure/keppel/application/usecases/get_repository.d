module uim.infrastructure.keppel.application.usecases.get_repository;

import uim.infrastructure.keppel.domain.entities.repository : Repository;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class GetRepositoryUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Repository* execute(string name) {
        return repository.findByName(name);
    }
}
