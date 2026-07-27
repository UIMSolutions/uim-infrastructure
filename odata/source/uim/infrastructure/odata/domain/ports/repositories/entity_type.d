/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.ports.repositories.entity_type;

import uim.infrastructure.odata.domain.entities.entity_type : EntityType;

interface IEntityTypeRepository {
    void save(in EntityType entityType);
    void update(in EntityType entityType);
    EntityType[] list();
    EntityType* findByName(string name);
    void deleteByName(string name);
}
