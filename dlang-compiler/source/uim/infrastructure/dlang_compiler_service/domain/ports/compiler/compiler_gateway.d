module uim.infrastructure.dlang_compiler_service.domain.ports.compiler.compiler_gateway;

import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompileRequest, CompileResult, CompilerProfile;

interface ICompilerGateway {
    CompileResult compile(CompileRequest request, CompilerProfile profile);
}
