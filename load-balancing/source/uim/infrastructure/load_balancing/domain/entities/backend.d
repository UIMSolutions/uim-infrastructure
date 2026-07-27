/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module lb_service.domain.entities.backend;

import std.format : format;

/// Represents a single backend server registered with the load balancer.
struct Backend {
    string id;
    string host;
    ushort port;
    uint weight;
    bool healthy;

    string address() const {
        return format!"http://%s:%d"(host, port);
    }
}

unittest {
    auto b = Backend("b1", "10.0.0.1", 8080, 1, true);
    assert(b.address() == "http://10.0.0.1:8080");
}
