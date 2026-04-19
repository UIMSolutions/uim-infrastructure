module uim.infrastructure.odata.domain.entities.navigation_property;

enum Multiplicity {
    one,
    many
}

struct NavigationProperty {
    string name;
    string targetEntityType;
    Multiplicity multiplicity;
    string partner;
}

unittest {
    auto np = NavigationProperty("Friends", "Person", Multiplicity.many, "");
    assert(np.name == "Friends");
    assert(np.targetEntityType == "Person");
    assert(np.multiplicity == Multiplicity.many);
}
