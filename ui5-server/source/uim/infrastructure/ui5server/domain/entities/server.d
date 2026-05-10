module uim.infrastructure.ui5server.domain.entities.server;

enum ServerStatus {
    stopped,
    starting,
    running,
    stopping,
    error
}

enum Protocol {
    http,
    https,
    h2
}

struct Server {
    string id;
    string name;
    ushort port = 8080;
    string host = "0.0.0.0";
    Protocol protocol = Protocol.http;
    bool acceptRemoteConnections = false;
    bool changePortIfInUse = false;
    bool simpleIndex = false;
    ServerStatus status = ServerStatus.stopped;
    string sslCertPath;
    string sslKeyPath;
    string[] middlewareNames;

    string summary() {
        import std.conv : to;
        return name ~ " (" ~ protocol.to!string ~ "://" ~ host ~ ":" ~ port.to!string ~ ") [" ~ status.to!string ~ "]";
    }

    unittest {
        auto s = Server("s1", "dev-server", 3000, "localhost", Protocol.http, false, false, false, ServerStatus.running);
        assert(s.port == 3000);
        assert(s.status == ServerStatus.running);
        assert(s.summary() == "dev-server (http://localhost:3000) [running]");
    }
}
