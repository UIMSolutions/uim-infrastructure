/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.infrastructure.mcp.application.usecases.call_tool : CallToolUseCase;
import uim.infrastructure.mcp.application.usecases.initialize_server : InitializeServerUseCase;
import uim.infrastructure.mcp.application.usecases.list_prompts : ListPromptsUseCase;
import uim.infrastructure.mcp.application.usecases.list_resources : ListResourcesUseCase;
import uim.infrastructure.mcp.application.usecases.list_tools : ListToolsUseCase;
import uim.infrastructure.mcp.infrastructure.http.controllers.mcp : McpController;
import uim.infrastructure.mcp.infrastructure.registry.memory_registry : InMemoryMcpRegistry;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto registry = new InMemoryMcpRegistry();
    auto serverName = readEnv("MCP_SERVER_NAME", "uim-mcp-service");
    auto serverVersion = readEnv("MCP_SERVER_VERSION", "0.1.0");

    auto controller = new McpController(
        new InitializeServerUseCase(serverName, serverVersion),
        new ListToolsUseCase(registry),
        new CallToolUseCase(registry),
        new ListResourcesUseCase(registry),
        new ListPromptsUseCase(registry)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("MCP service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
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
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
