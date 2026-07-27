/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
