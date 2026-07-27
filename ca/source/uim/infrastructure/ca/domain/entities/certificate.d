/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.domain.entities.certificate;

enum CertificateStatus {
    active,
    revoked
}

struct Certificate {
    string id;
    string commonName;
    string[] subjectAltNames;
    string certPem;
    string keyPem;
    string chainPem;
    string serialNumber;
    CertificateStatus status;
    string createdAt;
    string notBefore;
    string notAfter;
    string revokedAt;
    string revokedReason;
    string namespace;
}
