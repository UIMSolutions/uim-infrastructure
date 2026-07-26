module uim.infrastructure.ca.domain.entities.certificate;

enum CertificateStatus {
    active,
    revoked
}

struct Certificate {
    string id;
    string commonName;
    string[] subjectAltNames;
    string certPem;
    string keyPem;
    string chainPem;
    string serialNumber;
    CertificateStatus status;
    string createdAt;
    string notBefore;
    string notAfter;
    string revokedAt;
    string revokedReason;
    string namespace;
}
