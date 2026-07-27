/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.entities.version_info;

struct LibraryInfo {
    string name;
    string version_;
    string buildTimestamp;
}

struct VersionInfo {
    string name;
    string version_;
    string buildTimestamp;
    string scmRevision;
    LibraryInfo[] libraries;

    string summary() {
        import std.conv : to;
        return name ~ " v" ~ version_ ~ " (" ~ buildTimestamp ~ ") libs=" ~ libraries.length.to!string;
    }

    unittest {
        auto vi = VersionInfo("sap.ui.core", "1.120.0", "20260101120000", "abc123", []);
        assert(vi.name == "sap.ui.core");
        assert(vi.version_ == "1.120.0");
    }
}
