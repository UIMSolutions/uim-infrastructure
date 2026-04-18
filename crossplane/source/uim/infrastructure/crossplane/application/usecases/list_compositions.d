module uim.infrastructure.crossplane.application.usecases.list_compositions;

import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class ListCompositionsUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    Composition[] execute() { return repo.list(); }
}
