module uim.infrastructure.ca.domain.ports.crypto.ca_engine;

struct RootCaMaterial {
    string certPem;
    string keyPem;
    string serialNumber;
}

struct IssuedCertMaterial {
    string certPem;
    string keyPem;
    string chainPem;
    string serialNumber;
}

interface ICaCryptoEngine {
    RootCaMaterial createRootCa(string commonName, uint validDays);
    IssuedCertMaterial issueCertificate(
        string caCertPem,
        string caKeyPem,
        string commonName,
        string[] subjectAltNames,
        uint validDays
    );
}
