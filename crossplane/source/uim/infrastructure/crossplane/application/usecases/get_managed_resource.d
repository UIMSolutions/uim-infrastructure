module uim.infrastructure.crossplane.application.usecases.get_managed_resource;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class GetManagedResourceUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    ManagedResource* execute(string id) { return repo.findById(id); }
}
