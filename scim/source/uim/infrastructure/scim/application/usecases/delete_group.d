module uim.infrastructure.scim.application.usecases.delete_group;

import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;

class DeleteGroupUseCase {
    private IGroupRepository repository;

    this(IGroupRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        repository.remove(id);
    }
}
