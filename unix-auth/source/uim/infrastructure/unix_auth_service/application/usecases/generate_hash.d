module uim.infrastructure.unix_auth_service.application.usecases.generate_hash;

import uim.infrastructure.unix_auth_service.application.dto.password_command :
    GenerateHashCommand;
import uim.infrastructure.unix_auth_service.domain.ports.security.password_crypto :
    IPasswordCrypto;

struct GeneratedHash {
    string algorithm;
    string salt;
    string hash;
}

class GenerateHashUseCase {
    private IPasswordCrypto crypto;

    this(IPasswordCrypto crypto) {
        this.crypto = crypto;
    }

    GeneratedHash execute(GenerateHashCommand command) {
        if (command.password.length == 0) {
            throw new Exception("password is required");
        }

        auto algorithm = command.algorithm.length == 0 ? "sha512" : command.algorithm;
        auto salt = command.salt.length > 0 ? command.salt : crypto.createSalt(algorithm);
        auto hash = crypto.hashPassword(command.password, salt);

        return GeneratedHash(algorithm, salt, hash);
    }
}
