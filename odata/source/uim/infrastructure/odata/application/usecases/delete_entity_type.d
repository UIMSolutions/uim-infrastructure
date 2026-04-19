module uim.infrastructure.odata.application.usecases.delete_entity_type;

import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;

class DeleteEntityTypeUseCase {
    private IEntityTypeRepository repo;

    this(IEntityTypeRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        auto existing = repo.findByName(name);
        if (existing is null) return false;
        repo.deleteByName(name);
        return true;
    }
}
