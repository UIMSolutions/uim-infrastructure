module uim.infrastructure.crossplane.application.usecases.get_composite_resource;

import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource;
import uim.infrastructure.crossplane.domain.ports.repositories.composite_resource : ICompositeResourceRepository;

class GetCompositeResourceUseCase {
    private ICompositeResourceRepository repo;

    this(ICompositeResourceRepository repo) { this.repo = repo; }

    CompositeResource* execute(string id) { return repo.findById(id); }
}
