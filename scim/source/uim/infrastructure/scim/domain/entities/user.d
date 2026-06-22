module uim.infrastructure.scim.domain.entities.user;

import std.datetime : SysTime;

struct ScimUser {
    string id;
    string externalId;
    string userName;
    string displayName;
    string givenName;
    string familyName;
    string[] emails;
    SysTime createdAt;
    SysTime lastModifiedAt;
    string versionTag;
}

unittest {
    import std.datetime : Clock;

    auto user = ScimUser(
        "2819c223-7f76-453a-919d-413861904646",
        "dschrute",
        "dschrute",
        "Dwight K. Schrute",
        "Dwight",
        "Schrute",
        ["dschrute@example.com"],
        Clock.currTime(),
        Clock.currTime(),
        "W/\"v1\""
    );

    assert(user.userName == "dschrute");
    assert(user.emails.length == 1);
}
