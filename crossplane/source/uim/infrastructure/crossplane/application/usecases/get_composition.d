module uim.infrastructure.crossplane.application.usecases.get_composition;

import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class GetCompositionUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    Composition* execute(string id) { return repo.findById(id); }
}
