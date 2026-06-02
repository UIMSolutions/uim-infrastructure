module uim.infrastructure.keppel.application.usecases.list_tags;

import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class ListTagsUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    ImageTag[] execute(string repositoryName) {
        return repository.listTags(repositoryName);
    }
}
