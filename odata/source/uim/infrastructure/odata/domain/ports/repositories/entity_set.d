module uim.infrastructure.odata.domain.ports.repositories.entity_set;

import uim.infrastructure.odata.domain.entities.entity_set : EntitySet;

interface IEntitySetRepository {
    void save(in EntitySet entitySet);
    EntitySet[] list();
    EntitySet* findByName(string name);
    void deleteByName(string name);
}
