module uim.infrastructure.mcp.domain.entities.mcp_primitives;

struct McpToolAnnotations {
    bool readOnlyHint;
    bool destructiveHint;
    bool idempotentHint;
    bool openWorldHint;
}

struct McpToolDefinition {
    string name;
    string title;
    string description;
    string inputSchemaJson;
    McpToolAnnotations annotations;
}

struct McpToolCallResult {
    bool isError;
    string text;
    string structuredContentJson;
}

struct McpResourceDefinition {
    string uri;
    string name;
    string description;
    string mimeType;
}

struct McpPromptArgument {
    string name;
    string description;
    bool required;
}

struct McpPromptDefinition {
    string name;
    string description;
    McpPromptArgument[] arguments;
}
