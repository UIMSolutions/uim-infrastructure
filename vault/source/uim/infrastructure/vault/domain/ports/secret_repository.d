module uim.infrastructure.vault.domain.ports.secret_repository;

import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord, CertificateRecord;

interface ISecretRepository {
    SecretRecord[] listSecrets();
    SecretRecord createSecret(string path, string value, string ownerIdentity, string category, uint ttlSeconds);
    SecretRecord* getSecretById(string id);
    CertificateRecord issueCertificate(string commonName, string ownerIdentity, uint ttlSeconds);
    bool revokeCertificate(string serial);
    CertificateRecord[] listCertificates();
}
