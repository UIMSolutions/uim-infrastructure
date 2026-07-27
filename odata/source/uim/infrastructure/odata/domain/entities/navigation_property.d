/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
