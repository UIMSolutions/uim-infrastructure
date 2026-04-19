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
