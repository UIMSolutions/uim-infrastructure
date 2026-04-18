module uim.infrastructure.ansible.domain.entities.inventory;

import std.conv : to;

struct HostGroup {
    string name;
    string[] hostIds;
    string[string] groupVars;
}

struct Inventory {
    string id;
    string name;
    string description;
    HostGroup[] groups;

    string summary() const {
        return name ~ " (" ~ groups.length.to!string ~ " groups)";
    }
}

unittest {
    auto inv = Inventory("i1", "production", "Prod hosts", [
        HostGroup("webservers", ["h1", "h2"], null),
        HostGroup("dbservers", ["h3"], null)
    ]);
    assert(inv.summary() == "production (2 groups)");
}
