module monitoring_service.domain.entities.check;

/// Represents a registered health-check target.
struct Check {
    string id;
    string name;
    string host;
    ushort port;
    uint intervalSecs;
    bool active;

    string address() const {
        import std.format : format;
        return format!"http://%s:%d"(host, port);
    }
}

unittest {
    auto c = Check("c1", "api", "10.0.0.1", 8080, 30, true);
    assert(c.address() == "http://10.0.0.1:8080");
}
