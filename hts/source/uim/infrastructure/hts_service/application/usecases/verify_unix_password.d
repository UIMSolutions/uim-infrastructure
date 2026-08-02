module uim.infrastructure.hts_service.application.usecases.verify_unix_password;

import uim.infrastructure.hts_service.application.dto.unix_auth_commands :
    VerifyPasswordCommand;
import uim.infrastructure.hts_service.domain.ports.security.password_crypto :
    IPasswordCrypto;

class VerifyUnixPasswordUseCase {
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
