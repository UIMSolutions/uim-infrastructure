/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.dtos.csp;

struct ConfigureCspDTO {
    string name;
    string[string] directives;
    bool reportOnly = false;
}

struct CspPolicyResponseDTO {
    string name;
    string[string] directives;
    bool reportOnly;
}

struct CspReportDTO {
    string id;
    string documentUri;
    string violatedDirective;
    string blockedUri;
    string originalPolicy;
    string timestamp;
}

struct CspReportsResponseDTO {
    CspReportDTO[] reports;
    ulong totalCount;
}
