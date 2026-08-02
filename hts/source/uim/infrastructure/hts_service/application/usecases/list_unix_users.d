module uim.infrastructure.hts_service.application.usecases.list_unix_users;

import uim.infrastructure.hts_service.domain.entities.unix_user : UnixUser;
import uim.infrastructure.hts_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;

class ListUnixUsersUseCase {
    private IUnixAuthRepository repository;

    this(IUnixAuthRepository repository) {
        this.repository = repository;
    }

    UnixUser[] execute() {
        return repository.listUsers();
    }
}
