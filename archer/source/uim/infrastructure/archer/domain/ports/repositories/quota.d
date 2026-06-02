module uim.infrastructure.archer.domain.ports.repositories.quota;

import uim.infrastructure.archer.domain.entities.quota : ArcherQuota;

interface IQuotaRepository {
    void save(in ArcherQuota quota);
    ArcherQuota[] list();
    ArcherQuota* findByProjectId(string projectId);
    void remove(string projectId);
}
