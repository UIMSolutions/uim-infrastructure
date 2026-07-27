/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.entities.entity_set;

struct EntitySet {
    string name;
    string entityTypeName;
}

unittest {
    auto es = EntitySet("People", "Person");
    assert(es.name == "People");
    assert(es.entityTypeName == "Person");
}
