module uim.infrastructure.crossplane.application.usecases.delete_composition;

import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;

class DeleteCompositionUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    void execute(string id) { repo.remove(id); }
}
