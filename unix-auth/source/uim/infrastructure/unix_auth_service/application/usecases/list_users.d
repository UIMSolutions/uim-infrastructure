module uim.infrastructure.unix_auth_service.application.usecases.list_users;

import uim.infrastructure.unix_auth_service.domain.entities.unix_user : UnixUser;
import uim.infrastructure.unix_auth_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;

class ListUsersUseCase {
    private IUnixAuthRepository repository;

    this(IUnixAuthRepository repository) {
        this.repository = repository;
    }

    UnixUser[] execute() {
        return repository.listUsers();
    }
}
