module uim.infrastructure.odata.domain.ports.repositories.entity;

import uim.infrastructure.odata.domain.entities.entity : Entity;
import uim.infrastructure.odata.domain.entities.query_options : QueryOptions;

interface IEntityRepository {
    void save(string entitySetName, in Entity entity);
    void update(string entitySetName, string id, in Entity entity);
    Entity[] list(string entitySetName);
    Entity* findById(string entitySetName, string id);
    void deleteById(string entitySetName, string id);
    Entity[] query(string entitySetName, in QueryOptions options);
    ulong count(string entitySetName);
}
