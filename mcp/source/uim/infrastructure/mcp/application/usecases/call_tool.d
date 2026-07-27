/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mcp.application.usecases.call_tool;

import vibe.data.json : Json;
import uim.infrastructure.mcp.domain.entities.mcp_primitives : McpToolCallResult;
import uim.infrastructure.mcp.domain.ports.mcp_registry : IMcpRegistry;

class CallToolUseCase {
    private IMcpRegistry registry;

    this(IMcpRegistry registry) {
        this.registry = registry;
    }

    McpToolCallResult execute(string toolName, Json arguments) {
        return registry.callTool(toolName, arguments);
    }
}
