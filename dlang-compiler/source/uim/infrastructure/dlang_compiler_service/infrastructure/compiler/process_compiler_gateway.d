module uim.infrastructure.dlang_compiler_service.infrastructure.compiler.process_compiler_gateway;

import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompileRequest, CompileResult, CompilerProfile;
import uim.infrastructure.dlang_compiler_service.domain.ports.compiler.compiler_gateway :
    ICompilerGateway;
import std.array : appender;
import std.exception : collectException;
import std.file : mkdirRecurse, rmdirRecurse, tempDir, write;
import std.path : buildPath;
import std.process : execute;
import std.random : uniform;
import std.string : join;

class ProcessCompilerGateway : ICompilerGateway {
    override CompileResult compile(CompileRequest request, CompilerProfile profile) {
        auto workspace = buildPath(tempDir(), "uim-dlang-compiler-" ~ randomSuffix());
        mkdirRecurse(workspace);

        scope (exit) {
            if (workspace.length > 0) {
                collectException(rmdirRecurse(workspace));
            }
        }

        auto sourcePath = buildPath(workspace, request.fileName);
        write(sourcePath, request.sourceCode);

        auto argList = [sourcePath] ~ profile.args;
        auto command = [profile.executable] ~ argList;
        auto result = execute(command);

        return CompileResult(
            result.status == 0,
            result.status,
            result.output,
            "",
            join(command, " ")
        );
    }

    private string randomSuffix() {
        auto buffer = appender!string();
        foreach (_; 0 .. 8) {
            buffer.put(cast(char) ('a' + uniform(0, 26)));
        }
        return buffer.data;
    }
}
