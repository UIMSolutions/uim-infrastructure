module uim.infrastructure.unix_auth_service.application.usecases.get_user;

import uim.infrastructure.unix_auth_service.domain.entities.unix_user : MaybeUnixUser;
import uim.infrastructure.unix_auth_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;

class GetUserUseCase {
    private IUnixAuthRepository repository;

    this(IUnixAuthRepository repository) {
        this.repository = repository;
    }

    MaybeUnixUser execute(string username) {
        return repository.getUser(username);
    }
}
