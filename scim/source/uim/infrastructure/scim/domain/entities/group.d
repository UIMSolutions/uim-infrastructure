/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.domain.entities.group;

import std.datetime : SysTime;

struct ScimGroup {
    string id;
    string externalId;
    string displayName;
    string[] memberIds;
    SysTime createdAt;
    SysTime lastModifiedAt;
    string versionTag;
}

unittest {
    import std.datetime : Clock;

    auto group = ScimGroup(
        "e9e30dba-f08f-4109-8486-d5c6a331660a",
        "sales",
        "Sales Reps",
        ["2819c223-7f76-453a-919d-413861904646"],
        Clock.currTime(),
        Clock.currTime(),
        "W/\"v1\""
    );

    assert(group.displayName == "Sales Reps");
    assert(group.memberIds.length == 1);
}
