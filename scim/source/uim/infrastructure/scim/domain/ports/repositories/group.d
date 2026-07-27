/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.domain.ports.repositories.group;

import uim.infrastructure.scim.domain.entities.group : ScimGroup;

interface IGroupRepository {
    void save(ScimGroup group);
    ScimGroup[] list();
    ScimGroup* findById(string id);
    ScimGroup* findByDisplayName(string displayName);
    void remove(string id);
}
