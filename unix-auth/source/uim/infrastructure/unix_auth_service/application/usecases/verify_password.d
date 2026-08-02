module uim.infrastructure.unix_auth_service.application.usecases.verify_password;

import uim.infrastructure.unix_auth_service.application.dto.password_command :
    VerifyPasswordCommand;
import uim.infrastructure.unix_auth_service.domain.ports.security.password_crypto :
    IPasswordCrypto;

class VerifyPasswordUseCase {
    private IPasswordCrypto crypto;

    this(IPasswordCrypto crypto) {
        this.crypto = crypto;
    }

    bool execute(VerifyPasswordCommand command) {
        if (command.password.length == 0) {
            throw new Exception("password is required");
        }
        if (command.existingHash.length == 0) {
            throw new Exception("existingHash is required");
        }

        return crypto.verifyPassword(command.password, command.existingHash);
    }
}
