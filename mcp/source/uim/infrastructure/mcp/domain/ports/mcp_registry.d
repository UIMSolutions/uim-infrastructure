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
