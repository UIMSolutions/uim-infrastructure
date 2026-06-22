module uim.infrastructure.mcp.application.usecases.list_prompts;

import uim.infrastructure.mcp.domain.entities.mcp_primitives : McpPromptDefinition;
import uim.infrastructure.mcp.domain.ports.mcp_registry : IMcpRegistry;

class ListPromptsUseCase {
    private IMcpRegistry registry;

    this(IMcpRegistry registry) {
        this.registry = registry;
    }

    McpPromptDefinition[] execute() {
        return registry.listPrompts();
    }
}
