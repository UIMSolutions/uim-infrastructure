module uim.infrastructure.mcp.application.usecases.list_resources;

import uim.infrastructure.mcp.domain.entities.mcp_primitives : McpResourceDefinition;
import uim.infrastructure.mcp.domain.ports.mcp_registry : IMcpRegistry;

class ListResourcesUseCase {
    private IMcpRegistry registry;

    this(IMcpRegistry registry) {
        this.registry = registry;
    }

    McpResourceDefinition[] execute() {
        return registry.listResources();
    }
}
