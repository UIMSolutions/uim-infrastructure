/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
