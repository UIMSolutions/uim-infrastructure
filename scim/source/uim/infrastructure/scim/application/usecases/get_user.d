module uim.infrastructure.scim.application.usecases.get_user;

import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class GetUserUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    ScimUser* execute(string id) {
        return repository.findById(id);
    }
}
