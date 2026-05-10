module uim.infrastructure.ui5server.domain.entities.theme;

struct ThemeSource {
    string path;
    string lessContent;
}

struct Theme {
    string name;
    string library;
    ThemeSource[] sources;
    string compiledCss;
    bool compiled = false;
    string lastCompiled;

    string summary() {
        import std.conv : to;
        return name ~ " (" ~ library ~ ") sources=" ~ sources.length.to!string ~ " compiled=" ~ compiled.to!string;
    }

    unittest {
        auto t = Theme("sap_horizon", "sap.m", [], "", false, "");
        assert(t.name == "sap_horizon");
        assert(!t.compiled);
    }
}
