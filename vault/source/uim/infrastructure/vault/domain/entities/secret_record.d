/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.vault.domain.entities.secret_record;

struct SecretRecord {
    string id;
    string path;
    string value;
    string ownerIdentity;
    string category;
    ulong createdAtEpoch;
    ulong expiresAtEpoch;
}

struct CertificateRecord {
    string serial;
    string commonName;
    string ownerIdentity;
    ulong issuedAtEpoch;
    ulong expiresAtEpoch;
    bool revoked;
}
