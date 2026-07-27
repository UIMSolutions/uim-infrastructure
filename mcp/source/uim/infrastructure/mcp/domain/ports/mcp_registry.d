/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mcp.domain.ports.mcp_registry;

import vibe.data.json : Json;
import uim.infrastructure.mcp.domain.entities.mcp_primitives :
    McpToolDefinition,
    McpToolCallResult,
    McpResourceDefinition,
    McpPromptDefinition;

interface IMcpRegistry {
    McpToolDefinition[] listTools();
    McpToolCallResult callTool(string name, Json arguments);
    McpResourceDefinition[] listResources();
    McpPromptDefinition[] listPrompts();
}
