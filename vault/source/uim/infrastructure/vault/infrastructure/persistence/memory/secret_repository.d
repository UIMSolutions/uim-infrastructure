module uim.infrastructure.vault.infrastructure.persistence.memory.secret_repository;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord, CertificateRecord;
import uim.infrastructure.vault.domain.ports.secret_repository : ISecretRepository;

class InMemorySecretRepository : ISecretRepository {
    private SecretRecord[] secrets;
    private CertificateRecord[] certificates;
    private uint defaultTtlSeconds;

    this(uint defaultTtlSeconds) {
        this.defaultTtlSeconds = defaultTtlSeconds;
    }

    override SecretRecord[] listSecrets() {
        return secrets.dup;
    }

    override SecretRecord createSecret(string path, string value, string ownerIdentity, string category, uint ttlSeconds) {
        auto now = Clock.currTime.toUnixTime();
        auto ttl = ttlSeconds == 0 ? defaultTtlSeconds : ttlSeconds;

        auto record = SecretRecord(
            randomUUID().toString(),
            path,
            value,
            ownerIdentity,
            category,
            cast(ulong) now,
            cast(ulong) (now + ttl)
        );

        secrets ~= record;
        return record;
    }

    override SecretRecord* getSecretById(string id) {
        foreach (ref item; secrets) {
            if (item.id == id) {
                return &item;
            }
        }
        return null;
    }

    override CertificateRecord issueCertificate(string commonName, string ownerIdentity, uint ttlSeconds) {
        auto now = Clock.currTime.toUnixTime();
        auto ttl = ttlSeconds == 0 ? defaultTtlSeconds : ttlSeconds;

        auto record = CertificateRecord(
            "cert-" ~ randomUUID().toString(),
            commonName,
            ownerIdentity,
            cast(ulong) now,
            cast(ulong) (now + ttl),
            false
        );

        certificates ~= record;
        return record;
    }

    override bool revokeCertificate(string serial) {
        foreach (ref cert; certificates) {
            if (cert.serial == serial) {
                cert.revoked = true;
                return true;
            }
        }
        return false;
    }

    override CertificateRecord[] listCertificates() {
        return certificates.dup;
    }
}
