module uim.infrastructure.crossplane.domain.ports.repositories.composition;

import uim.infrastructure.crossplane.domain.entities.composition : Composition;

interface ICompositionRepository {
    void save(in Composition composition);
    void remove(string id);
    Composition[] list();
    Composition* findById(string id);
}
