module uim.infrastructure.vault.domain.entities.secret_record;

struct SecretRecord {
    string id;
    string path;
    string value;
    string ownerIdentity;
    string category;
    ulong createdAtEpoch;
    ulong expiresAtEpoch;
}

struct CertificateRecord {
    string serial;
    string commonName;
    string ownerIdentity;
    ulong issuedAtEpoch;
    ulong expiresAtEpoch;
    bool revoked;
}
