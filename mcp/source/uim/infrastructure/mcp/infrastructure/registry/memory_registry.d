module uim.infrastructure.mcp.infrastructure.registry.memory_registry;

import std.conv : to;
import std.exception : collectException;
import std.string : replace;
import uim.infrastructure.mcp.domain.entities.mcp_primitives :
    McpToolAnnotations,
    McpToolCallResult,
    McpToolDefinition,
    McpResourceDefinition,
    McpPromptArgument,
    McpPromptDefinition;
import uim.infrastructure.mcp.domain.ports.mcp_registry : IMcpRegistry;
import vibe.data.json : Json;

class InMemoryMcpRegistry : IMcpRegistry {
    override McpToolDefinition[] listTools() {
        McpToolDefinition[] tools;

        tools ~= McpToolDefinition(
            "echo",
            "Echo Tool",
            "Echoes the input message",
            q{"type":"object","properties":{"message":{"type":"string","description":"Message to echo"}},"required":["message"]},
            McpToolAnnotations(true, false, true, false)
        );

        tools ~= McpToolDefinition(
            "get-sum",
            "Get Sum Tool",
            "Returns the sum of two numbers",
            q{"type":"object","properties":{"a":{"type":"number"},"b":{"type":"number"}},"required":["a","b"]},
            McpToolAnnotations(true, false, true, false)
        );

        tools ~= McpToolDefinition(
            "get-env",
            "Print Environment Tool",
            "Returns process environment variables",
            q{"type":"object","properties":{}},
            McpToolAnnotations(true, false, true, false)
        );

        return tools;
    }

    override McpToolCallResult callTool(string name, Json arguments) {
        if (name == "echo") {
            auto msg = arguments["message"].type == Json.Type.string
                ? arguments["message"].get!string
                : "";
            if (msg.length == 0) {
                return McpToolCallResult(true, "message is required", "");
            }
            return McpToolCallResult(false, "Echo: " ~ msg, q{{"message": "} ~ escapeJson(msg) ~ q{"}});
        }

        if (name == "get-sum") {
            bool okA;
            bool okB;
            auto a = parseNumber(arguments["a"], okA);
            auto b = parseNumber(arguments["b"], okB);
            if (!okA || !okB) {
                return McpToolCallResult(true, "a and b must be numeric", "");
            }

            auto sum = a + b;
            auto text = "The sum of " ~ a.to!string ~ " and " ~ b.to!string ~ " is " ~ sum.to!string ~ ".";
            return McpToolCallResult(false, text, "{\"sum\": " ~ sum.to!string ~ "}");
        }

        if (name == "get-env") {
            return McpToolCallResult(false, "Environment details are intentionally redacted in this demo server.", "{}");
        }

        return McpToolCallResult(true, "unknown tool: " ~ name, "");
    }

    override McpResourceDefinition[] listResources() {
        McpResourceDefinition[] resources;
        resources ~= McpResourceDefinition(
            "mcp://server/instructions",
            "server-instructions",
            "High-level instructions for this MCP demo service",
            "text/plain"
        );
        resources ~= McpResourceDefinition(
            "mcp://server/features",
            "server-features",
            "Capabilities and primitive list inspired by MCP reference servers",
            "application/json"
        );
        return resources;
    }

    override McpPromptDefinition[] listPrompts() {
        McpPromptDefinition[] prompts;

        McpPromptArgument[] summarizeArgs;
        summarizeArgs ~= McpPromptArgument("topic", "Topic to summarize", true);
        prompts ~= McpPromptDefinition(
            "summarize-topic",
            "Summarize a provided topic into concise bullets",
            summarizeArgs
        );

        McpPromptArgument[] checklistArgs;
        checklistArgs ~= McpPromptArgument("goal", "Goal for implementation checklist", true);
        prompts ~= McpPromptDefinition(
            "implementation-checklist",
            "Generate a practical implementation checklist",
            checklistArgs
        );

        return prompts;
    }

    private double parseNumber(Json input, out bool ok) {
        ok = true;
        final switch (input.type) {
            case Json.Type.float_:
                return input.get!double;
            case Json.Type.int_:
                return cast(double) input.get!long;
            case Json.Type.bigInt:
                double parsedBigInt;
                auto errBigInt = collectException(parsedBigInt = input.get!string.to!double);
                if (errBigInt is null) {
                    return parsedBigInt;
                }
                ok = false;
                return 0.0;
            case Json.Type.string:
                double parsedString;
                auto errString = collectException(parsedString = input.get!string.to!double);
                if (errString is null) {
                    return parsedString;
                }
                ok = false;
                return 0.0;
            case Json.Type.undefined:
            case Json.Type.null_:
            case Json.Type.bool_:
            case Json.Type.array:
            case Json.Type.object:
                ok = false;
                return 0.0;
        }
    }

    private string escapeJson(string value) {
        auto escaped = value.replace("\\", "\\\\");
        escaped = escaped.replace("\"", "\\\"");
        return escaped;
    }
}
