module uim.infrastructure.ui5server.domain.entities.resource;

struct Resource {
    string path;
    string contentType;
    ulong size;
    string lastModified;
    string content;
    bool isDirectory = false;

    string summary() {
        import std.conv : to;
        return path ~ " (" ~ contentType ~ ", " ~ size.to!string ~ " bytes)";
    }

    unittest {
        auto r = Resource("/index.html", "text/html", 1024, "2026-01-01T00:00:00Z", "<html></html>", false);
        assert(r.path == "/index.html");
        assert(r.contentType == "text/html");
        assert(!r.isDirectory);
    }
}
