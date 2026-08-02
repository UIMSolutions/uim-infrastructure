module uim.infrastructure.dlang_compiler_service.domain.entities.compile_result;

struct CompilerProfile {
    string name;
    string executable;
    string[] args;
}

struct CompileRequest {
    string sourceCode;
    string fileName;
    string profile;
}

struct CompileResult {
    bool success;
    int exitCode;
    string stdoutText;
    string stderrText;
    string command;
}
