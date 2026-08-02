module app;

import uim.infrastructure.dlang_compiler_service.application.usecases.compile_source :
    CompileSourceUseCase;
import uim.infrastructure.dlang_compiler_service.application.usecases.list_profiles :
    ListProfilesUseCase;
import uim.infrastructure.dlang_compiler_service.domain.entities.compile_result :
    CompilerProfile;
import uim.infrastructure.dlang_compiler_service.infrastructure.compiler.process_compiler_gateway :
    ProcessCompilerGateway;
import uim.infrastructure.dlang_compiler_service.infrastructure.http.controllers.api_controller :
    ApiController;
import uim.infrastructure.dlang_compiler_service.infrastructure.http.controllers.web_controller :
    WebController;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto compilerGateway = new ProcessCompilerGateway();
    auto profiles = readProfiles();

    auto compileUseCase = new CompileSourceUseCase(compilerGateway, profiles);
    auto listProfilesUseCase = new ListProfilesUseCase(profiles);

    auto apiController = new ApiController(compileUseCase, listProfilesUseCase);
    auto webController = new WebController(compileUseCase, listProfilesUseCase);

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("D compiler service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private CompilerProfile[] readProfiles() {
    auto compilerExe = readEnv("DLANG_COMPILER", "dmd");

    return [
        CompilerProfile("debug", compilerExe, ["-c", "-of/dev/null"]),
        CompilerProfile("release", compilerExe, ["-O", "-release", "-c", "-of/dev/null"])
    ];
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}

private string readEnv(string key, string fallback) {
    auto raw = getenv(toStringz(key));
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
