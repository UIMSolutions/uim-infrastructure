module uim.infrastructure.ca.infrastructure.persistence.memory.certificate_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ca.domain.entities.certificate : Certificate, CertificateStatus;
import uim.infrastructure.ca.domain.ports.repositories.certificate : ICertificateRepository;

class InMemoryCertificateRepository : ICertificateRepository {
    private Certificate[] certificates;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Certificate certificate) {
        synchronized (mutex) {
            foreach (i, ref existing; certificates) {
                if (existing.id == certificate.id) {
                    certificates[i] = copyCertificate(certificate);
                    return;
                }
            }
            certificates ~= copyCertificate(certificate);
        }
    }

    override Certificate[] list(string namespaceName = "") {
        synchronized (mutex) {
            if (namespaceName.length == 0)
                return certificates.dup;

            Certificate[] result;
            foreach (certificate; certificates) {
                if (certificate.namespace == namespaceName)
                    result ~= certificate;
            }
            return result;
        }
    }

    override Certificate* findById(string id) {
        synchronized (mutex) {
            foreach (ref certificate; certificates) {
                if (certificate.id == id)
                    return &certificate;
            }
            return null;
        }
    }

    override bool revoke(string id, string reason, string revokedAt) {
        synchronized (mutex) {
            foreach (ref certificate; certificates) {
                if (certificate.id == id) {
                    certificate.status = CertificateStatus.revoked;
                    certificate.revokedReason = reason;
                    certificate.revokedAt = revokedAt;
                    return true;
                }
            }
            return false;
        }
    }

    private Certificate copyCertificate(in Certificate src) {
        Certificate dst;
        dst.id = src.id;
        dst.commonName = src.commonName;
        dst.subjectAltNames = src.subjectAltNames.dup;
        dst.certPem = src.certPem;
        dst.keyPem = src.keyPem;
        dst.chainPem = src.chainPem;
        dst.serialNumber = src.serialNumber;
        dst.status = src.status;
        dst.createdAt = src.createdAt;
        dst.notBefore = src.notBefore;
        dst.notAfter = src.notAfter;
        dst.revokedAt = src.revokedAt;
        dst.revokedReason = src.revokedReason;
        dst.namespace = src.namespace;
        return dst;
    }
}
