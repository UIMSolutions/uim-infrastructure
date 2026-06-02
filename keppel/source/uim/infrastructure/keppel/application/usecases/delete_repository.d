module uim.infrastructure.keppel.application.usecases.delete_repository;

import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class DeleteRepositoryUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        if (!repository.remove(name)) {
            throw new Exception("repository not found");
        }
    }
}
