module uim.infrastructure.odata.application.usecases.delete_entity;

import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;

class DeleteEntityUseCase {
    private IEntityRepository repo;

    this(IEntityRepository repo) {
        this.repo = repo;
    }

    bool execute(string entitySetName, string id) {
        auto existing = repo.findById(entitySetName, id);
        if (existing is null) return false;
        repo.deleteById(entitySetName, id);
        return true;
    }
}
