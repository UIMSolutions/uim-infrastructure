module uim.infrastructure.scim.application.usecases.delete_user;

import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class DeleteUserUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        repository.remove(id);
    }
}
