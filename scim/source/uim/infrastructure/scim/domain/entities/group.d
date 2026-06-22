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
