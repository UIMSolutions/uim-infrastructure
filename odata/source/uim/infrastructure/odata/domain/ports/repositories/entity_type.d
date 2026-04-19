module uim.infrastructure.odata.domain.ports.repositories.entity_type;

import uim.infrastructure.odata.domain.entities.entity_type : EntityType;

interface IEntityTypeRepository {
    void save(in EntityType entityType);
    void update(in EntityType entityType);
    EntityType[] list();
    EntityType* findByName(string name);
    void deleteByName(string name);
}
