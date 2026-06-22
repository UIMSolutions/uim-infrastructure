module uim.infrastructure.scim.domain.ports.repositories.group;

import uim.infrastructure.scim.domain.entities.group : ScimGroup;

interface IGroupRepository {
    void save(ScimGroup group);
    ScimGroup[] list();
    ScimGroup* findById(string id);
    ScimGroup* findByDisplayName(string displayName);
    void remove(string id);
}
