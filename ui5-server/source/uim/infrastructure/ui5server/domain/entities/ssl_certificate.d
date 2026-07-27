/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.entities.ssl_certificate;

struct SslCertificate {
    string id;
    string certPath;
    string keyPath;
    bool valid = false;
    string issuedTo;
    string issuedBy;
    string validFrom;
    string validUntil;

    string summary() {
        return (valid ? "VALID" : "INVALID") ~ " cert for " ~ issuedTo ~ " (" ~ validFrom ~ " - " ~ validUntil ~ ")";
    }

    unittest {
        auto c = SslCertificate("c1", "/certs/server.crt", "/certs/server.key", true, "localhost", "UI5 Dev CA", "2026-01-01", "2027-01-01");
        assert(c.valid == true);
        assert(c.certPath == "/certs/server.crt");
    }
}
