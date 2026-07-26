module uim.infrastructure.ca.domain.ports.repositories.certificate;

import uim.infrastructure.ca.domain.entities.certificate : Certificate;

interface ICertificateRepository {
    void save(in Certificate certificate);
    Certificate[] list(string namespaceName = "");
    Certificate* findById(string id);
    bool revoke(string id, string reason, string revokedAt);
}
