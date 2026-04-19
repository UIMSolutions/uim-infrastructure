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
