/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.entities.entity;

struct Entity {
    string entitySetName;
    string entityTypeName;
    string[string] properties;
    string id;
}

unittest {
    auto e = Entity("People", "Person", ["UserName": "russellwhyte", "FirstName": "Russell"], "russellwhyte");
    assert(e.entitySetName == "People");
    assert(e.properties["FirstName"] == "Russell");
}
