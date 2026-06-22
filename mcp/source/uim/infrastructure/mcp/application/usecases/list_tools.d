module uim.infrastructure.mcp.application.usecases.list_tools;

import uim.infrastructure.mcp.domain.entities.mcp_primitives : McpToolDefinition;
import uim.infrastructure.mcp.domain.ports.mcp_registry : IMcpRegistry;

class ListToolsUseCase {
    private IMcpRegistry registry;

    this(IMcpRegistry registry) {
        this.registry = registry;
    }

    McpToolDefinition[] execute() {
        return registry.listTools();
    }
}
