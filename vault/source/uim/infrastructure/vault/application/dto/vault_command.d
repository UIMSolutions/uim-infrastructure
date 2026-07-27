/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.vault.application.dto.vault_command;

struct CreateSecretCommand {
    string path;
    string value;
    string ownerIdentity;
    string category;
    uint ttlSeconds;
}

struct IssueCertificateCommand {
    string commonName;
    string ownerIdentity;
    uint ttlSeconds;
}
