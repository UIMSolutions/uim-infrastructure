module uim.infrastructure.crossplane.domain.ports.repositories.managed_resource;

import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;

interface IManagedResourceRepository {
    void save(in ManagedResource resource);
    void remove(string id);
    ManagedResource[] list();
    ManagedResource* findById(string id);
    ManagedResource[] findByProviderId(string providerId);
    ManagedResource[] findByCompositeRef(string compositeRef);
}
