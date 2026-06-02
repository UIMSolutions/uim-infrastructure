module uim.infrastructure.keppel.application.usecases.get_manifest;

import uim.infrastructure.keppel.domain.entities.manifest : Manifest;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class GetManifestUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Manifest* execute(string repositoryName, string reference) {
        return repository.findManifest(repositoryName, reference);
    }
}
