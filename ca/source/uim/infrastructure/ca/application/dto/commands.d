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
