module uim.infrastructure.crossplane.domain.ports.repositories.claim;

import uim.infrastructure.crossplane.domain.entities.claim : Claim;

interface IClaimRepository {
    void save(in Claim claim);
    void remove(string id);
    Claim[] list();
    Claim* findById(string id);
    Claim[] findByNamespace(string namespace);
}
