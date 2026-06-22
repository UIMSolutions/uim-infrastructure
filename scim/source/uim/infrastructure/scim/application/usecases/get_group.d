module uim.infrastructure.scim.application.usecases.get_group;

import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;

class GetGroupUseCase {
    private IGroupRepository repository;

    this(IGroupRepository repository) {
        this.repository = repository;
    }

    ScimGroup* execute(string id) {
        return repository.findById(id);
    }
}
