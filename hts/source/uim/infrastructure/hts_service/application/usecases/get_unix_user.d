module uim.infrastructure.hts_service.application.usecases.get_unix_user;

import uim.infrastructure.hts_service.domain.entities.unix_user : MaybeUnixUser;
import uim.infrastructure.hts_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;

class GetUnixUserUseCase {
    private IUnixAuthRepository repository;

    this(IUnixAuthRepository repository) {
        this.repository = repository;
    }

    MaybeUnixUser execute(string username) {
        return repository.getUser(username);
    }
}
