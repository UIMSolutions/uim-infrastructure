/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.application.dto.commands;

struct InitializeCaCommand {
    string name;
    string commonName;
    uint validDays;
}

struct IssueCertificateCommand {
    string commonName;
    string[] subjectAltNames;
    uint validDays;
    string namespaceName;
}

struct RevokeCertificateCommand {
    string certificateId;
    string reason;
}
