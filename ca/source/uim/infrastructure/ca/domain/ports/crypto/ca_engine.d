/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
