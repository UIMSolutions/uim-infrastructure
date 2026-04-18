module uim.infrastructure.crossplane.domain.ports.repositories.composite_resource;

import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource;

interface ICompositeResourceRepository {
    void save(in CompositeResource resource);
    void remove(string id);
    CompositeResource[] list();
    CompositeResource* findById(string id);
    CompositeResource[] findByCompositionId(string compositionId);
}
