module uim.infrastructure.dlang_formatter_service.domain.entities.format_result;

struct FormatterProfile {
    string name;
    string executable;
    string[] args;
}

struct FormatRequest {
    string sourceCode;
    string fileName;
    string profile;
}

struct FormatResult {
    bool success;
    int exitCode;
    string formattedCode;
    string stdoutText;
    string stderrText;
    string command;
}
