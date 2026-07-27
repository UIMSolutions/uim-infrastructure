/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
            "leanix-overview",
            "LeanIX Overview Tool",
            "Returns a concise SAP LeanIX enterprise architecture overview",
            q{"type":"object","properties":{}},
            McpToolAnnotations(true, false, true, false)
        );

        tools ~= McpToolDefinition(
            "leanix-fact-sheet-template",
            "LeanIX Fact Sheet Template Tool",
            "Builds a starter fact sheet payload aligned with SAP LeanIX key concepts",
            q{"type":"object","properties":{"factSheetType":{"type":"string","description":"Fact sheet type such as Application, BusinessCapability, ITComponent"},"name":{"type":"string","description":"Fact sheet display name"},"owner":{"type":"string","description":"Responsible owner"},"lifecycle":{"type":"string","description":"Lifecycle stage"}},"required":["factSheetType","name"]},
            McpToolAnnotations(true, false, true, false)
        );

        tools ~= McpToolDefinition(
            "leanix-roadmap-checklist",
            "LeanIX Roadmap Checklist Tool",
            "Returns an enterprise architecture roadmap checklist based on SAP LeanIX getting-started guidance",
            q{"type":"object","properties":{"transformationGoal":{"type":"string","description":"Transformation objective"},"timeHorizon":{"type":"string","description":"Planning horizon such as 12m or 24m"}},"required":["transformationGoal"]},
            McpToolAnnotations(true, false, true, false)
        );

        return tools;
    }

    override McpToolCallResult callTool(string name, Json arguments) {
        if (name == "leanix-overview") {
            auto text = "SAP LeanIX provides a 360 degree view of applications, business capabilities, and IT components to align IT strategy with business goals and support transformation planning.";
            return McpToolCallResult(
                false,
                text,
                q{{"focus":["application portfolio","business capabilities","it components"],"outcomes":["alignment","risk visibility","roadmap planning"]}}
            );
        }

        if (name == "leanix-fact-sheet-template") {
            auto factSheetType = arguments["factSheetType"].type == Json.Type.string
                ? arguments["factSheetType"].get!string
                : "";
            auto nameValue = arguments["name"].type == Json.Type.string
                ? arguments["name"].get!string
                : "";

            if (factSheetType.length == 0 || nameValue.length == 0) {
                return McpToolCallResult(true, "factSheetType and name are required", "");
            }

            auto owner = arguments["owner"].type == Json.Type.string
                ? arguments["owner"].get!string
                : "unassigned";
            auto lifecycle = arguments["lifecycle"].type == Json.Type.string
                ? arguments["lifecycle"].get!string
                : "planned";

            auto text = "Generated LeanIX fact sheet template for " ~ factSheetType ~ " named " ~ nameValue ~ ".";
            auto payload =
                q{{"factSheet":{"type":"} ~ escapeJson(factSheetType) ~
                q{","name":"} ~ escapeJson(nameValue) ~
                q{","owner":"} ~ escapeJson(owner) ~
                q{","lifecycle":"} ~ escapeJson(lifecycle) ~
                q{","attributes":{"technicalFit":"unknown","functionalFit":"unknown"}}}};
            return McpToolCallResult(false, text, payload);
        }

        if (name == "leanix-roadmap-checklist") {
            auto goal = arguments["transformationGoal"].type == Json.Type.string
                ? arguments["transformationGoal"].get!string
                : "";
            if (goal.length == 0) {
                return McpToolCallResult(true, "transformationGoal is required", "");
            }

            auto horizon = arguments["timeHorizon"].type == Json.Type.string
                ? arguments["timeHorizon"].get!string
                : "12m";

            auto text = "Prepared LeanIX roadmap checklist for goal: " ~ goal ~ ".";
            auto payload =
                q{{"timeHorizon":"} ~ escapeJson(horizon) ~
                q{","steps":["define target architecture","map dependencies in meta model","prioritize applications by fit and risk","assign owners and collaboration workflows","track progress with reports and diagrams"]}};
            return McpToolCallResult(false, text, payload);
        }

        return McpToolCallResult(true, "unknown tool: " ~ name, "");
    }

    override McpResourceDefinition[] listResources() {
        McpResourceDefinition[] resources;
        resources ~= McpResourceDefinition(
            "mcp://leanix/introduction",
            "leanix-introduction",
            "Introduction summary for SAP LeanIX enterprise architecture management",
            "text/plain"
        );
        resources ~= McpResourceDefinition(
            "mcp://leanix/key-concepts",
            "leanix-key-concepts",
            "Fact sheets, meta model, collaboration, and reporting concepts",
            "application/json"
        );
        resources ~= McpResourceDefinition(
            "mcp://leanix/products",
            "leanix-products",
            "LeanIX product scope including APM, architecture roadmap planning, and technology risk/compliance",
            "application/json"
        );
        return resources;
    }

    override McpPromptDefinition[] listPrompts() {
        McpPromptDefinition[] prompts;

        McpPromptArgument[] bootstrapArgs;
        bootstrapArgs ~= McpPromptArgument("organizationName", "Organization name", true);
        bootstrapArgs ~= McpPromptArgument("scope", "Initial architecture scope", true);
        prompts ~= McpPromptDefinition(
            "leanix-workspace-bootstrap",
            "Create an initial SAP LeanIX workspace onboarding plan",
            bootstrapArgs
        );

        McpPromptArgument[] collaborationArgs;
        collaborationArgs ~= McpPromptArgument("domain", "Architecture domain to govern", true);
        prompts ~= McpPromptDefinition(
            "leanix-collaboration-cadence",
            "Generate a collaboration cadence using surveys, subscriptions, comments, and to-dos",
            collaborationArgs
        );

        return prompts;
    }

    private string escapeJson(string value) {
        auto escaped = value.replace("\\", "\\\\");
        escaped = escaped.replace("\"", "\\\"");
        return escaped;
    }
}
