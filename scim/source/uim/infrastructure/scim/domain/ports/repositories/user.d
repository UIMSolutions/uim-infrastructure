/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.domain.ports.repositories.user;

import uim.infrastructure.scim.domain.entities.user : ScimUser;

interface IUserRepository {
    void save(ScimUser user);
    ScimUser[] list();
    ScimUser* findById(string id);
    ScimUser* findByUserName(string userName);
    void remove(string id);
}
