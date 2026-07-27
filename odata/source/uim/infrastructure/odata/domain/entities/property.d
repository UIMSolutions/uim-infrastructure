/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.entities.property;

enum EdmType {
    string_,
    int32,
    int64,
    boolean_,
    double_,
    decimal_,
    dateTimeOffset,
    guid,
    binary,
    single,
    byte_,
    stream
}

struct Property {
    string name;
    EdmType type;
    bool nullable;
    string defaultValue;
    uint maxLength;
}

unittest {
    auto p = Property("FirstName", EdmType.string_, false, "", 256);
    assert(p.name == "FirstName");
    assert(p.type == EdmType.string_);
    assert(!p.nullable);
}
