module uim.infrastructure.hts_service.application.usecases.generate_unix_hash;

import uim.infrastructure.hts_service.application.dto.unix_auth_commands :
    GenerateHashCommand;
import uim.infrastructure.hts_service.domain.ports.security.password_crypto :
    IPasswordCrypto;

struct GeneratedUnixHash {
    string algorithm;
    string salt;
    string hash;
}

class GenerateUnixHashUseCase {
    private IPasswordCrypto crypto;

    this(IPasswordCrypto crypto) {
        this.crypto = crypto;
    }

    GeneratedUnixHash execute(GenerateHashCommand command) {
        if (command.password.length == 0) {
            throw new Exception("password is required");
        }

        auto algorithm = command.algorithm.length == 0 ? "sha512" : command.algorithm;
        auto salt = command.salt.length > 0 ? command.salt : crypto.createSalt(algorithm);
        auto hash = crypto.hashPassword(command.password, salt);

        return GeneratedUnixHash(algorithm, salt, hash);
    }
}
