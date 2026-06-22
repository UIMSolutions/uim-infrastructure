module uim.infrastructure.vault.application.dto.vault_command;

struct CreateSecretCommand {
    string path;
    string value;
    string ownerIdentity;
    string category;
    uint ttlSeconds;
}

struct IssueCertificateCommand {
    string commonName;
    string ownerIdentity;
    uint ttlSeconds;
}
