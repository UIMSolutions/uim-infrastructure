module uim.infrastructure.crossplane.application.usecases.list_managed_resources;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class ListManagedResourcesUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    ManagedResource[] execute() { return repo.list(); }
}
