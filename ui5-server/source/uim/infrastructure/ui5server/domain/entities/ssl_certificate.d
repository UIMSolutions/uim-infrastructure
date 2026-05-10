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
