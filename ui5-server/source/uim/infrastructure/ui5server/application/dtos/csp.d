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
