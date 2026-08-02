module uim.infrastructure.unix_auth_service.application.usecases.set_password;

import uim.infrastructure.unix_auth_service.application.dto.password_command :
    SetPasswordCommand;
import uim.infrastructure.unix_auth_service.domain.entities.unix_user : UnixUser;
import uim.infrastructure.unix_auth_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;
import uim.infrastructure.unix_auth_service.domain.ports.security.password_crypto :
    IPasswordCrypto;
import std.datetime.systime : Clock;

class SetPasswordUseCase {
    private IUnixAuthRepository repository;
    private IPasswordCrypto crypto;

    this(IUnixAuthRepository repository, IPasswordCrypto crypto) {
        this.repository = repository;
        this.crypto = crypto;
    }

    UnixUser execute(SetPasswordCommand command) {
        if (command.username.length == 0) {
            throw new Exception("username is required");
        }
        if (command.password.length == 0) {
            throw new Exception("password is required");
        }

        auto algorithm = command.algorithm.length == 0 ? "sha512" : command.algorithm;
        auto salt = crypto.createSalt(algorithm);
        auto hash = crypto.hashPassword(command.password, salt);

        return repository.setPasswordHash(command.username, hash, currentShadowDay());
    }

    private long currentShadowDay() {
        return cast(long) (Clock.currTime.toUnixTime / 86_400);
    }
}
