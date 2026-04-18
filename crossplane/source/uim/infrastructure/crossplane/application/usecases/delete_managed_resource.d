module uim.infrastructure.crossplane.application.usecases.delete_managed_resource;

import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;

class DeleteManagedResourceUseCase {
    private IManagedResourceRepository repo;

    this(IManagedResourceRepository repo) { this.repo = repo; }

    void execute(string id) { repo.remove(id); }
}
