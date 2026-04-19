module uim.infrastructure.odata.domain.entities.entity_type;

import std.conv : to;
import uim.infrastructure.odata.domain.entities.property : Property;
import uim.infrastructure.odata.domain.entities.navigation_property : NavigationProperty;

struct EntityType {
    string name;
    string namespace_;
    string[] keyProperties;
    Property[] properties;
    NavigationProperty[] navigationProperties;

    string fullName() const {
        if (namespace_.length > 0)
            return namespace_ ~ "." ~ name;
        return name;
    }
}

unittest {
    auto et = EntityType(
        "Person",
        "TripPin",
        ["UserName"],
        [Property("UserName", Property.init.type, false, "", 0)],
        [],
    );
    assert(et.fullName() == "TripPin.Person");
}
