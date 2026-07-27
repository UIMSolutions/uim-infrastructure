/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.entities.middleware;

enum MiddlewareType {
    csp,
    compression,
    cors,
    discovery,
    serveResources,
    testRunner,
    serveThemes,
    versionInfo,
    nonReadRequests,
    serveIndex,
    custom
}

struct Middleware {
    string name;
    MiddlewareType type;
    uint order;
    bool enabled = true;
    string[string] config;

    string summary() {
        import std.conv : to;
        return name ~ " (" ~ type.to!string ~ ") order=" ~ order.to!string ~ " enabled=" ~ enabled.to!string;
    }

    unittest {
        auto m = Middleware("csp", MiddlewareType.csp, 1, true);
        assert(m.name == "csp");
        assert(m.type == MiddlewareType.csp);
        assert(m.enabled == true);
    }
}
