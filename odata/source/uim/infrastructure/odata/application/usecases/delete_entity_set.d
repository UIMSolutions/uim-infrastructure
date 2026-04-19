module uim.infrastructure.odata.application.usecases.delete_entity_set;

import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;

class DeleteEntitySetUseCase {
    private IEntitySetRepository repo;

    this(IEntitySetRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        auto existing = repo.findByName(name);
        if (existing is null) return false;
        repo.deleteByName(name);
        return true;
    }
}
