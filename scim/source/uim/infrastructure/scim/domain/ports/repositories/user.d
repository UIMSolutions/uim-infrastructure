module uim.infrastructure.scim.domain.ports.repositories.user;

import uim.infrastructure.scim.domain.entities.user : ScimUser;

interface IUserRepository {
    void save(ScimUser user);
    ScimUser[] list();
    ScimUser* findById(string id);
    ScimUser* findByUserName(string userName);
    void remove(string id);
}
