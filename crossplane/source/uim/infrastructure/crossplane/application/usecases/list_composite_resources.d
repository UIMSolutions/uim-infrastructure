module uim.infrastructure.crossplane.application.usecases.list_composite_resources;

import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource;
import uim.infrastructure.crossplane.domain.ports.repositories.composite_resource : ICompositeResourceRepository;

class ListCompositeResourcesUseCase {
    private ICompositeResourceRepository repo;

    this(ICompositeResourceRepository repo) { this.repo = repo; }

    CompositeResource[] execute() { return repo.list(); }
}
