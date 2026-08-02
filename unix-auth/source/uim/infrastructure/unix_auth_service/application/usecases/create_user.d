module uim.infrastructure.unix_auth_service.application.usecases.create_user;

import uim.infrastructure.unix_auth_service.application.dto.create_user_command :
    CreateUserCommand;
import uim.infrastructure.unix_auth_service.domain.entities.unix_user : PasswdEntry,
    ShadowEntry, UnixUser;
import uim.infrastructure.unix_auth_service.domain.ports.repositories.unix_auth_repository :
    IUnixAuthRepository;
import uim.infrastructure.unix_auth_service.domain.ports.security.password_crypto :
    IPasswordCrypto;
import std.datetime.systime : Clock;

class CreateUserUseCase {
    private IUnixAuthRepository repository;
    private IPasswordCrypto crypto;

    this(IUnixAuthRepository repository, IPasswordCrypto crypto) {
        this.repository = repository;
        this.crypto = crypto;
    }

    UnixUser execute(CreateUserCommand command) {
        validate(command);

        auto salt = crypto.createSalt("sha512");
        auto hash = crypto.hashPassword(command.password, salt);

        auto passwdEntry = PasswdEntry(
            command.username,
            "x",
            command.uid,
            command.gid,
            command.gecos,
            command.homeDirectory,
            command.loginShell
        );

        auto shadowEntry = ShadowEntry(
            command.username,
            hash,
            currentShadowDay(),
            0,
            99_999,
            7,
            -1,
            -1,
            ""
        );

        return repository.createUser(passwdEntry, shadowEntry);
    }

    private void validate(CreateUserCommand command) {
        if (command.username.length == 0) {
            throw new Exception("username is required");
        }
        if (command.homeDirectory.length == 0) {
            throw new Exception("homeDirectory is required");
        }
        if (command.loginShell.length == 0) {
            throw new Exception("loginShell is required");
        }
        if (command.password.length == 0) {
            throw new Exception("password is required");
        }
    }

    private long currentShadowDay() {
        return cast(long) (Clock.currTime.toUnixTime / 86_400);
    }
}
