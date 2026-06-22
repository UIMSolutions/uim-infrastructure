module uim.infrastructure.mcp.infrastructure.http.controllers.mcp;

import std.conv : to;
import uim.infrastructure.mcp.application.usecases.call_tool : CallToolUseCase;
import uim.infrastructure.mcp.application.usecases.initialize_server : InitializeServerUseCase;
import uim.infrastructure.mcp.application.usecases.list_prompts : ListPromptsUseCase;
import uim.infrastructure.mcp.application.usecases.list_resources : ListResourcesUseCase;
import uim.infrastructure.mcp.application.usecases.list_tools : ListToolsUseCase;
import uim.infrastructure.mcp.domain.entities.mcp_primitives : McpToolDefinition;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class McpController {
    private InitializeServerUseCase initializeServerUseCase;
    private ListToolsUseCase listToolsUseCase;
    private CallToolUseCase callToolUseCase;
    private ListResourcesUseCase listResourcesUseCase;
    private ListPromptsUseCase listPromptsUseCase;

    this(
        InitializeServerUseCase initializeServerUseCase,
        ListToolsUseCase listToolsUseCase,
        CallToolUseCase callToolUseCase,
        ListResourcesUseCase listResourcesUseCase,
        ListPromptsUseCase listPromptsUseCase
    ) {
        this.initializeServerUseCase = initializeServerUseCase;
        this.listToolsUseCase = listToolsUseCase;
        this.callToolUseCase = callToolUseCase;
        this.listResourcesUseCase = listResourcesUseCase;
        this.listPromptsUseCase = listPromptsUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.post("/mcp", &rpc);
        router.post("/v1/mcp", &rpc);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["status"] = Json("ok");
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void rpc(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        auto method = body["method"].type == Json.Type.string ? body["method"].get!string : "";
        auto id = body["id"];
        auto params = body["params"];

        if (body["jsonrpc"].type != Json.Type.string || body["jsonrpc"].get!string != "2.0") {
            writeJson(res, serializeToJsonString(errorResponse(id, -32600, "Invalid Request")), HTTPStatus.badRequest);
            return;
        }

        final switch (method) {
            case "initialize": {
                auto info = initializeServerUseCase.execute();
                Json result = Json.emptyObject;
                result["protocolVersion"] = Json("2025-03-26");
                result["serverInfo"] = serverInfoJson(info.name, info.serverVersion);
                result["capabilities"] = capabilitiesJson();
                writeJson(res, serializeToJsonString(successResponse(id, result)), HTTPStatus.ok);
                return;
            }
            case "tools/list": {
                Json result = Json.emptyObject;
                result["tools"] = toolsToJson(listToolsUseCase.execute());
                writeJson(res, serializeToJsonString(successResponse(id, result)), HTTPStatus.ok);
                return;
            }
            case "tools/call": {
                auto toolName = params["name"].type == Json.Type.string ? params["name"].get!string : "";
                if (toolName.length == 0) {
                    writeJson(res, serializeToJsonString(errorResponse(id, -32602, "Invalid params: name is required")), HTTPStatus.badRequest);
                    return;
                }

                auto toolResult = callToolUseCase.execute(toolName, params["arguments"]);

                Json result = Json.emptyObject;
                result["content"] = toolContentJson(toolResult.text);
                result["isError"] = Json(toolResult.isError);
                if (toolResult.structuredContentJson.length > 0) {
                    result["structuredContent"] = parseJsonString(toolResult.structuredContentJson);
                }

                writeJson(res, serializeToJsonString(successResponse(id, result)), HTTPStatus.ok);
                return;
            }
            case "resources/list": {
                Json result = Json.emptyObject;
                result["resources"] = resourcesToJson();
                writeJson(res, serializeToJsonString(successResponse(id, result)), HTTPStatus.ok);
                return;
            }
            case "prompts/list": {
                Json result = Json.emptyObject;
                result["prompts"] = promptsToJson();
                writeJson(res, serializeToJsonString(successResponse(id, result)), HTTPStatus.ok);
                return;
            }
        }

        writeJson(res, serializeToJsonString(errorResponse(id, -32601, "Method not found")), HTTPStatus.notFound);
    }

    private Json successResponse(Json id, Json result) {
        Json payload = Json.emptyObject;
        payload["jsonrpc"] = Json("2.0");
        payload["id"] = id.type == Json.Type.undefined ? Json(null) : id;
        payload["result"] = result;
        return payload;
    }

    private Json errorResponse(Json id, int code, string message) {
        Json payload = Json.emptyObject;
        payload["jsonrpc"] = Json("2.0");
        payload["id"] = id.type == Json.Type.undefined ? Json(null) : id;

        Json err = Json.emptyObject;
        err["code"] = Json(code);
        err["message"] = Json(message);
        payload["error"] = err;
        return payload;
    }

    private Json capabilitiesJson() {
        Json capabilities = Json.emptyObject;

        Json tools = Json.emptyObject;
        tools["listChanged"] = Json(false);
        capabilities["tools"] = tools;

        Json resources = Json.emptyObject;
        resources["subscribe"] = Json(false);
        resources["listChanged"] = Json(false);
        capabilities["resources"] = resources;

        Json prompts = Json.emptyObject;
        prompts["listChanged"] = Json(false);
        capabilities["prompts"] = prompts;

        return capabilities;
    }

    private Json serverInfoJson(string name, string serverVersion) {
        Json info = Json.emptyObject;
        info["name"] = Json(name);
        info["version"] = Json(serverVersion);
        return info;
    }

    private Json toolsToJson(McpToolDefinition[] tools) {
        Json[] items;
        foreach (tool; tools) {
            Json item = Json.emptyObject;
            item["name"] = Json(tool.name);
            item["title"] = Json(tool.title);
            item["description"] = Json(tool.description);
            item["inputSchema"] = parseJsonString(tool.inputSchemaJson);

            Json ann = Json.emptyObject;
            ann["readOnlyHint"] = Json(tool.annotations.readOnlyHint);
            ann["destructiveHint"] = Json(tool.annotations.destructiveHint);
            ann["idempotentHint"] = Json(tool.annotations.idempotentHint);
            ann["openWorldHint"] = Json(tool.annotations.openWorldHint);
            item["annotations"] = ann;

            items ~= item;
        }
        return Json(items);
    }

    private Json resourcesToJson() {
        auto resources = listResourcesUseCase.execute();
        Json[] items;
        foreach (resource; resources) {
            Json item = Json.emptyObject;
            item["uri"] = Json(resource.uri);
            item["name"] = Json(resource.name);
            item["description"] = Json(resource.description);
            item["mimeType"] = Json(resource.mimeType);
            items ~= item;
        }
        return Json(items);
    }

    private Json promptsToJson() {
        auto prompts = listPromptsUseCase.execute();
        Json[] items;
        foreach (prompt; prompts) {
            Json item = Json.emptyObject;
            item["name"] = Json(prompt.name);
            item["description"] = Json(prompt.description);

            Json[] args;
            foreach (arg; prompt.arguments) {
                Json argItem = Json.emptyObject;
                argItem["name"] = Json(arg.name);
                argItem["description"] = Json(arg.description);
                argItem["required"] = Json(arg.required);
                args ~= argItem;
            }

            item["arguments"] = Json(args);
            items ~= item;
        }
        return Json(items);
    }

    private Json toolContentJson(string text) {
        Json entry = Json.emptyObject;
        entry["type"] = Json("text");
        entry["text"] = Json(text);
        return Json([entry]);
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
