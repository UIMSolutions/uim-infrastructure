module uim.infrastructure.ansible.domain.entities.host;

import std.conv : to;
import std.string : toUpper;

enum HostStatus {
    REACHABLE,
    UNREACHABLE,
    UNKNOWN
}

struct Host {
    string id;
    string hostname;
    string ipAddress;
    ushort port;
    string user;
    HostStatus status;
    string[string] variables;

    string summary() const {
        return hostname ~ " (" ~ ipAddress ~ ":" ~ port.to!string ~ ") [" ~ status.to!string ~ "]";
    }
}

HostStatus parseHostStatus(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, HostStatus)) {
        if (candidate == normalized)
            return to!HostStatus(normalized);
    }
    throw new Exception("Unsupported host status: " ~ raw);
}

unittest {
    assert(parseHostStatus("reachable") == HostStatus.REACHABLE);
    assert(parseHostStatus("UNREACHABLE") == HostStatus.UNREACHABLE);

    auto h = Host("h1", "web01", "10.0.0.1", 22, "deploy", HostStatus.REACHABLE, null);
    assert(h.summary() == "web01 (10.0.0.1:22) [REACHABLE]");
}
