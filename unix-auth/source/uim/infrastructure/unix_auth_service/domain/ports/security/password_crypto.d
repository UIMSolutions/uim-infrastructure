module uim.infrastructure.unix_auth_service.domain.ports.security.password_crypto;

interface IPasswordCrypto {
    string createSalt(string algorithm, uint length = 16);
    string hashPassword(string password, string saltSpec);
    bool verifyPassword(string password, string existingHash);
}
