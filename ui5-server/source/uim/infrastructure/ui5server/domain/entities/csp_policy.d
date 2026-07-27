/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.entities.csp_policy;

struct CspPolicy {
    string name;
    string[string] directives;
    bool reportOnly = false;

    string summary() {
        import std.conv : to;
        return name ~ (reportOnly ? " (report-only)" : " (enforced)") ~ " directives=" ~ directives.length.to!string;
    }

    unittest {
        string[string] dirs;
        dirs["default-src"] = "'self'";
        auto p = CspPolicy("sap-target-level-1", dirs, true);
        assert(p.name == "sap-target-level-1");
        assert(p.reportOnly == true);
    }
}

struct CspReport {
    string id;
    string documentUri;
    string violatedDirective;
    string blockedUri;
    string originalPolicy;
    string timestamp;

    unittest {
        auto r = CspReport("r1", "http://localhost/index.html", "script-src", "http://evil.com", "default-src 'self'", "2026-01-01T00:00:00Z");
        assert(r.violatedDirective == "script-src");
    }
}
