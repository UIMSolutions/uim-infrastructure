module uim.infrastructure.dlang_compiler_service.application.usecases.compile_source;

import uim.infrastructure.dlang_compiler_service.application.dto.compile_command :
    CompileCommand;
import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompileRequest, CompileResult, CompilerProfile;
import uim.infrastructure.dlang_compiler_service.domain.ports.compiler.compiler_gateway :
    ICompilerGateway;

class CompileSourceUseCase {
    private ICompilerGateway compilerGateway;
    private CompilerProfile[string] profiles;

    this(ICompilerGateway compilerGateway, CompilerProfile[] profiles) {
        this.compilerGateway = compilerGateway;
        foreach (profile; profiles) {
            this.profiles[profile.name] = profile;
        }
    }

    CompileResult execute(CompileCommand command) {
        if (command.sourceCode.length == 0) {
            throw new Exception("sourceCode is required");
        }

        auto profileName = command.profile.length == 0 ? "debug" : command.profile;
        if (!(profileName in profiles)) {
            throw new Exception("unknown profile: " ~ profileName);
        }

        auto fileName = command.fileName.length == 0 ? "snippet.d" : command.fileName;

        auto request = CompileRequest(command.sourceCode, fileName, profileName);
        return compilerGateway.compile(request, profiles[profileName]);
    }
}
