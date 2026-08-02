module app;

import uim.infrastructure.dlang_formatter_service.application.usecases.format_source :
    FormatSourceUseCase;
import uim.infrastructure.dlang_formatter_service.application.usecases.list_profiles :
    ListProfilesUseCase;
import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatterProfile;
import uim.infrastructure.dlang_formatter_service.infrastructure.formatter.process_formatter_gateway :
    ProcessFormatterGateway;
import uim.infrastructure.dlang_formatter_service.infrastructure.http.controllers.api_controller :
    ApiController;
import uim.infrastructure.dlang_formatter_service.infrastructure.http.controllers.web_controller :
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

    auto formatterGateway = new ProcessFormatterGateway();
    auto profiles = readProfiles();

    auto formatUseCase = new FormatSourceUseCase(formatterGateway, profiles);
    auto listProfilesUseCase = new ListProfilesUseCase(profiles);

    auto apiController = new ApiController(formatUseCase, listProfilesUseCase);
    auto webController = new WebController(formatUseCase, listProfilesUseCase);

    auto router = new URLRouter;
    apiController.registerRoutes(router);
    webController.registerRoutes(router);

    logInfo("D formatter service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private FormatterProfile[] readProfiles() {
    auto formatterExe = readEnv("DLANG_FORMATTER", "dfmt");

    return [
        FormatterProfile("default", formatterExe, []),
        FormatterProfile("check", formatterExe, ["--check"])
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
