/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
