module uim.infrastructure.keppel.application.usecases.delete_tag;

import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class DeleteTagUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    void execute(string repositoryName, string tagName) {
        if (!repository.deleteTag(repositoryName, tagName)) {
            throw new Exception("tag not found");
        }
    }
}
