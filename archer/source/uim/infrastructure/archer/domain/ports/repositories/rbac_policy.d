module uim.infrastructure.archer.domain.ports.repositories.rbac_policy;

import uim.infrastructure.archer.domain.entities.rbac_policy : ArcherRbacPolicy;

interface IRbacPolicyRepository {
    void save(in ArcherRbacPolicy policy);
    ArcherRbacPolicy[] list();
    ArcherRbacPolicy* findById(string id);
    void remove(string id);
}
